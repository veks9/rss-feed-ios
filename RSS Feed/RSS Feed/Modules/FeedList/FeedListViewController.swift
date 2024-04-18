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
    
    // MARK: - Views
    
    private let addFeedNavigationItem = UIBarButtonItem(
        image: Assets.plus.systemImage,
        style: .plain,
        target: FeedListViewController.self,
        action: nil
    )
    
    private let showFavoritesNavigationItem = UIBarButtonItem(
        image: nil,
        style: .plain,
        target: FeedListViewController.self,
        action: nil
    )
    
    private lazy var feedListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.keyboardDismissMode = .onDrag
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
        navigationItem.title = "feed_list_navigation_title".localized()
        navigationItem.leftBarButtonItem = showFavoritesNavigationItem
        navigationItem.rightBarButtonItem = addFeedNavigationItem
    }
    
    private func addSubviews() {
        view.addSubview(feedListTableView)
    }
    
    private func setConstraints() {
        feedListTableView.snp.remakeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func observe() {
        viewModel.showFavoritesImage
            .sink(receiveValue: { [weak self] showFavoritesImage in
                guard let self else { return }
                showFavoritesNavigationItem.image = showFavoritesImage
            })
            .store(in: &cancellables)
        
        addFeedNavigationItem.tapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                viewModel.onAddFeedTap()
            })
            .store(in: &cancellables)
        
        showFavoritesNavigationItem.tapPublisher
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                viewModel.onShowFavoritesTap()
            })
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDelegate

extension FeedListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
