//
//  FeedItemsListViewController.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 20.04.2024..
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

final class FeedItemsListViewController: UIViewController {
    
    private let viewModel: FeedItemsListViewModeling
    
    private var cancellables = Set<AnyCancellable>()
    
    typealias DataSource = UITableViewDiffableDataSource<FeedItemsListSectionType, FeedItemsListCellType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<FeedItemsListSectionType, FeedItemsListCellType>
    private lazy var dataSource: DataSource = makeDataSource()
    
    // MARK: - Views
    
    private let markAsFavoriteNavigationItem = UIBarButtonItem(
        image: nil,
        style: .plain,
        target: FeedItemsListViewController.self,
        action: nil
    )
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(FeedItemCell.self, forCellReuseIdentifier: FeedItemCell.identity)
        tableView.register(EmptyCell.self, forCellReuseIdentifier: EmptyCell.identity)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.keyboardDismissMode = .onDrag
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: FeedItemsListViewModeling) {
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
        navigationItem.title = viewModel.navigationTitle
        navigationItem.rightBarButtonItem = markAsFavoriteNavigationItem
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
        viewModel.markAsFavoriteImage
            .sink(receiveValue: { [weak self] markAsFavoriteImage in
                guard let self else { return }
                markAsFavoriteNavigationItem.image = markAsFavoriteImage
            })
            .store(in: &cancellables)

        viewModel.dataSource
            .sink(receiveValue: { [weak self] dataSource in
                guard let self else { return }
                refreshControl.endRefreshing()
                applySnapshot(sections: dataSource)
            })
            .store(in: &cancellables)
        
        refreshControl.isRefreshingPublisher
            .sink(receiveValue: { [weak self] isRefreshing in
                guard let self, isRefreshing else { return }
                viewModel.onPullToRefresh()
            })
            .store(in: &cancellables)
        
        markAsFavoriteNavigationItem.tapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                viewModel.onMarkAsFavoriteTap()
            })
            .store(in: &cancellables)
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            tableView: tableView
        ) { tableView, indexPath, itemIdentifier -> UITableViewCell? in
            switch itemIdentifier {
            case .feedItem(let cellViewModel):
                let cell: FeedItemCell = tableView.dequeueCellAtIndexPath(indexPath: indexPath)
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
    
    private func applySnapshot(sections: [FeedItemsListSection]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections.map{ $0.section} )
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section.section)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UITableViewDelegate

extension FeedItemsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .feedItem(let cellViewModel):
            viewModel.onRowSelect(with: cellViewModel)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .feedItem:
            return UITableView.automaticDimension
        case .empty:
            return tableView.frame.height
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .feedItem:
            return UITableView.automaticDimension
        case .empty:
            return tableView.frame.height
        default:
            return UITableView.automaticDimension
        }
    }
}
