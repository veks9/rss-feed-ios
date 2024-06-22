//
//  FeedListViewController.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

final class FeedListViewController: UIViewController {
    
    private let viewModel: FeedListViewModeling
    
    private var cancellables = Set<AnyCancellable>()
    
    typealias DataSource = UITableViewDiffableDataSource<FeedListSectionType, FeedListCellType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<FeedListSectionType, FeedListCellType>
    private lazy var dataSource: DataSource = makeDataSource()
    
    // MARK: - Views
    
    private lazy var loadingSpinnerView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        
        return view
    }()
    
    private lazy var loadingSpinnerNavigationItem = UIBarButtonItem(customView: loadingSpinnerView)
    
    private let addFeedNavigationItem = UIBarButtonItem(
        image: Assets.plus.systemImage,
        style: .plain,
        target: FeedListViewController.self,
        action: nil
    )
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(FeedCell.self, forCellReuseIdentifier: FeedCell.identity)
        tableView.register(EmptyCell.self, forCellReuseIdentifier: EmptyCell.identity)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate = self
        
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: FeedListViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleView()
        addSubviews()
        setConstraints()
        observe()
        
        viewModel.onViewDidLoad()
    }
    
    private func styleView() {
        view.backgroundColor = .white
        navigationItem.title = Localization.feedListNavigationTitle.localized()
        navigationItem.leftBarButtonItem = loadingSpinnerNavigationItem
        navigationItem.rightBarButtonItem = addFeedNavigationItem
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func setConstraints() {
        tableView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func observe() {
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                guard let self else { return }
                isLoading ? loadingSpinnerView.startAnimating() : loadingSpinnerView.stopAnimating()
            })
            .store(in: &cancellables)
        
        viewModel.dataSource
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] dataSource in
                guard let self else { return }
                applySnapshot(sections: dataSource)
            })
            .store(in: &cancellables)
        
        addFeedNavigationItem.tapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                viewModel.onAddFeedTap()
            })
            .store(in: &cancellables)
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            tableView: tableView
        ) { tableView, indexPath, itemIdentifier -> UITableViewCell? in
            switch itemIdentifier {
            case .feed(let cellViewModel):
                let cell: FeedCell = tableView.dequeueCellAtIndexPath(indexPath: indexPath)
                cell.updateUI(viewModel: cellViewModel)

                return cell
            case .empty(let cellViewModel):
                let cell: EmptyCell = tableView.dequeueCellAtIndexPath(indexPath: indexPath)
                cell.updateUI(viewModel: cellViewModel)

                return cell
            }
        }
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }
    
    private func applySnapshot(sections: [FeedListSection]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections.map{ $0.section} )
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section.section)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UITableViewDelegate

extension FeedListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .feed(let cellViewModel):
            viewModel.onRowSelect(with: cellViewModel)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .feed:
            return UITableView.automaticDimension
        case .empty:
            return tableView.frame.height
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .feed:
            return UITableView.automaticDimension
        case .empty:
            return tableView.frame.height
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .feed(let cellViewModel):
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, handler in
                self?.viewModel.onSwipeToDelete(with: cellViewModel)
            }
            deleteAction.backgroundColor = .red
            deleteAction.image = Assets.trash.systemImage?.withTintColor(.white)
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = true
            
            return configuration
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        
        let label = UILabel()
        label.set(textColor: .black, font: .systemFont(ofSize: 20, weight: .bold))
        
        containerView.addSubview(label)
        
        label.snp.remakeConstraints {
            $0.verticalEdges.equalToSuperview().inset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        switch dataSource.sectionIdentifier(for: section) {
        case .standard:
            label.text = nil
        case .favorited:
            label.text = Localization.feedListFavoritesSectionTitle.localized()
        case .feeds:
            label.text = Localization.feedListFeedsSectionTitle.localized()
        default:
            label.text = nil
        }
        
        return containerView
    }
}
