//
//  FeedListViewModel.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit
import Combine
import CombineExt
import FeedKit

protocol FeedListViewModeling {
    var showFavoritesImage: AnyPublisher<UIImage?, Never> { get }
    var dataSource: AnyPublisher<[FeedListSection], Never> { get }
    var handleAddingFeed: AnyPublisher<Void, Never> { get }
    
    func onViewDidLoad()
    func onRowSelect(with cellViewModel: FeedCellViewModel)
    func onAddFeedTap()
    func onShowFavoritesTap()
    func onSwipeToDelete(with cellViewModel: FeedCellViewModel)
    func onMarkFeedFavorite(with cellViewModel: FeedCellViewModel)
}

final class FeedListViewModel: FeedListViewModeling {
    
    private let router: FeedListRouting
    private let userDefaultsService: UserDefaultsServicing
    private let feedService: FeedServicing
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let isFavoritesIconSelected = CurrentValueSubject<Bool, Never>(false)
    private let itemForDeletionIdSubject = PassthroughSubject<String, Never>()
    private let itemForInsertionUrlSubject = PassthroughSubject<URL, Never>()
    
    init(
        router: FeedListRouting,
        userDefaultsService: UserDefaultsServicing = UserDefaultsService.shared,
        feedService: FeedServicing = FeedService.shared
    ) {
        self.router = router
        self.userDefaultsService = userDefaultsService
        self.feedService = feedService
    }
    
    var showFavoritesImage: AnyPublisher<UIImage?, Never> {
        Publishers.CombineLatest(
            viewDidLoadSubject,
            isFavoritesIconSelected
        )
        .map { _, isFavoritesIconSelected in
            isFavoritesIconSelected ? Assets.starFill.systemImage : Assets.star.systemImage
        }
        .eraseToAnyPublisher()
    }
    
    lazy var models: AnyPublisher<[RSSFeed], Never> = {
        viewDidLoadSubject
            .flatMap { [userDefaultsService] _ in
                userDefaultsService.feedUrls
            }
            .flatMapLatest({ [feedService] feedUrls in
                feedService.getFeeds(for: feedUrls.compactMap { URL(string: $0) })
                    .catch({ error in
                        print("🔴🔴🔴🔴\(error)🔴🔴🔴🔴")
                        return Empty<[RSSFeed], Never>(completeImmediately: false).eraseToAnyPublisher()
                    })
                    .ignoreFailure()
            })
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
    
    lazy var dataSource: AnyPublisher<[FeedListSection], Never> = {
        models
            .map { [weak self] models in
                guard let self else { return [] }
                return createFeedCells(from: models)
            }
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
    
    var handleAddingFeed: AnyPublisher<Void, Never> {
        itemForInsertionUrlSubject
            .withLatestFrom(userDefaultsService.feedUrls) { ($0, $1) }
            .handleEvents(receiveOutput: { [weak self] itemForInsertionUrl, feedUrls in
                guard let self else { return }
                if feedUrls.contains(itemForInsertionUrl.absoluteString) {
                    // TODO: - error, already exists
                } else {
                    var newFeedUrls = feedUrls
                    newFeedUrls.append(itemForInsertionUrl.absoluteString)
                    userDefaultsService.setFeedUrls(newFeedUrls)
                }
            })
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    private func addFeed(with urlString: String?) {
        // TODO: - check if this is rss
        if let urlString = urlString, let url = URL(string: urlString)  {
            itemForInsertionUrlSubject.send(url)
        } else {
            // TODO: - show error wrong url
        }
    }
    
    private func createFeedCells(from models: [RSSFeed]) -> [FeedListSection] {
        let emptyCell = FeedListCellType.empty(
            EmptyCellViewModel(
                id: "emptyCell",
                image: Assets.plus.systemImage,
                descriptionText: "feed_list_empty_description".localized()
            )
        )
        return models.isEmpty ?
        [FeedListSection(section: .standard, items: [emptyCell])] :
        [FeedListSection(section: .standard, items: getCells(from: models))]
    }
    
    private func getCells(from models: [RSSFeed]) -> [FeedListCellType] {
        var dataSource: [FeedListCellType] = []
        let cells = getFeedCells(from: models)
        dataSource.append(contentsOf: cells)
        
        return dataSource
    }
    
    private func getFeedCells(from models: [RSSFeed]) -> [FeedListCellType] {
        models.map { feed in
            .feed(
                FeedCellViewModel(
                    id: UUID().uuidString,
                    title: feed.title ?? "[-]",
                    description: feed.description ?? "[-]",
                    imageUrl: feed.image?.url,
                    isFavorited: false
                )
            )
        }
    }
}

// MARK: - Internal functions

extension FeedListViewModel {
    func onViewDidLoad() {
        viewDidLoadSubject.send()
    }
    
    func onRowSelect(with cellViewModel: FeedCellViewModel) {
        router.navigateToFeedItemsList(context: FeedItemsListContext())
    }
    
    func onAddFeedTap() {
        router.presentAddNewFeedAlert { [weak self] feedUrl in
            self?.addFeed(with: feedUrl)
        }
    }
    
    func onShowFavoritesTap() {
        isFavoritesIconSelected.send(!isFavoritesIconSelected.value)
    }
    
    func onSwipeToDelete(with cellViewModel: FeedCellViewModel) {
        itemForDeletionIdSubject.send(cellViewModel.id)
    }
    
    func onMarkFeedFavorite(with cellViewModel: FeedCellViewModel) {}
}
