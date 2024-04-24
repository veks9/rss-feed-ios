//
//  FeedItemsListViewModel.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 20.04.2024..
//

import UIKit
import Combine
import CombineExt

protocol FeedItemsListViewModeling {
    var navigationTitle: AnyPublisher<String, Never> { get }
    var markAsFavoriteImage: AnyPublisher<UIImage?, Never> { get }
    var dataSource: AnyPublisher<[FeedItemsListSection], Never> { get }
    var handleFavoriteButtonTap: AnyPublisher<Void, Never> { get }
    var handlePullToRefresh: AnyPublisher<Void, Never> { get }
    
    func onViewDidLoad()
    func onMarkAsFavoriteTap()
    func onRowSelect(with cellViewModel: FeedItemCellViewModel)
    func onPullToRefresh()
}

final class FeedItemsListViewModel: FeedItemsListViewModeling {
    
    private let context: FeedItemsListContext
    private let router: FeedItemsListRouting
    private let feedService: FeedServicing
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let pullToRefreshSubject = PassthroughSubject<Void, Never>()
    private let favoritesIconSelectedSubject = PassthroughSubject<Void, Never>()
    
    init(
        context: FeedItemsListContext,
        router: FeedItemsListRouting,
        feedService: FeedServicing = FeedService.shared
    ) {
        self.context = context
        self.router = router
        self.feedService = feedService
    }
    
    var navigationTitle: AnyPublisher<String, Never> {
        parentFeed
            .map {
                $0.title ?? "[-]"
            }
            .eraseToAnyPublisher()
    }
    
    lazy var parentFeed: AnyPublisher<FeedModel, Never> = {
        Publishers.Merge(
            viewDidLoadSubject,
            feedService.feedsChanged
        )
        .flatMap { [feedService, context] _ in
            feedService.getFeed(by: context.parentFeedId)
                .catch({ error in
                    // TODO: - handle error
                    return Empty<FeedModel, Never>(completeImmediately: false)
                })
                .ignoreFailure()
        }
        .share(replay: 1)
        .eraseToAnyPublisher()
    }()
    
    var markAsFavoriteImage: AnyPublisher<UIImage?, Never> {
        Publishers.CombineLatest(
            viewDidLoadSubject,
            parentFeed
        )
        .map { _, parentFeed in
            parentFeed.isFavorited ? Assets.starFill.systemImage : Assets.star.systemImage
        }
        .eraseToAnyPublisher()
    }
    
    lazy var dataSource: AnyPublisher<[FeedItemsListSection], Never> = {
        viewDidLoadSubject
            .flatMap({ [parentFeed] _ in
                parentFeed
            })
            .map({ [weak self] parentFeed in
                guard let self else { return [
                    FeedItemsListSection(
                        section: .standard,
                        items: [
                            FeedItemsListCellType.empty(
                                EmptyCellViewModel(
                                    id: "emptyCell",
                                    image: nil,
                                    descriptionText: "feed_items_list_empty_description".localized()
                                )
                            )
                        ]
                    )
                ] }
                return createFeedCells(from: parentFeed.itemsArray)
            })
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
    
    var handleFavoriteButtonTap: AnyPublisher<Void, Never> {
        favoritesIconSelectedSubject
            .withLatestFrom(parentFeed)
            .flatMapLatest({ [feedService] parentFeed in
                parentFeed.isFavorited.toggle()
                return feedService.updateFeed(feed: parentFeed)
                    .catch { error in
                        // TODO: - handle error
                        return Empty<FeedModel, Never>(completeImmediately: false).eraseToAnyPublisher()
                    }
                    .ignoreFailure()
            })
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    var handlePullToRefresh: AnyPublisher<Void, Never> {
        pullToRefreshSubject
            .flatMapLatest { [feedService, context] _ in
                feedService.fetchFeed(for: URL(string: context.parentFeedId)!)
                    .catch({ error in
                        // TODO: - handle error
                        print("🔴🔴🔴🔴\(error)🔴🔴🔴🔴")
                        return Empty<FeedModel, Never>(completeImmediately: false)
                    })
                    .ignoreFailure()
            }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    private func createFeedCells(from models: [FeedItemModel]) -> [FeedItemsListSection] {
        let emptyCell = FeedItemsListCellType.empty(
            EmptyCellViewModel(
                id: "emptyCell",
                image: nil,
                descriptionText: "feed_items_list_empty_description".localized()
            )
        )
        return models.isEmpty ?
        [FeedItemsListSection(section: .standard, items: [emptyCell])] :
        [FeedItemsListSection(section: .standard, items: getCells(from: models))]
    }
    
    private func getCells(from models: [FeedItemModel]) -> [FeedItemsListCellType] {
        var dataSource: [FeedItemsListCellType] = []
        dataSource.append(contentsOf: getFeedItemCells(from: models))
        
        return dataSource
    }
    
    private func getFeedItemCells(from models: [FeedItemModel]) -> [FeedItemsListCellType] {
        models.map { item in
            .feedItem(
                FeedItemCellViewModel(
                    id: item.id ?? UUID().uuidString,
                    title: item.title ?? "[-]",
                    description: item.itemDescription,
                    imageUrl: item.imageUrl,
                    datePublished: item.datePublished,
                    link: item.link
                )
            )
        }
    }
}

// MARK: - Internal functions

extension FeedItemsListViewModel {
    func onViewDidLoad() {
        viewDidLoadSubject.send()
    }
    
    func onMarkAsFavoriteTap() {
        favoritesIconSelectedSubject.send()
    }
    
    func onRowSelect(with cellViewModel: FeedItemCellViewModel) {
        if let link = cellViewModel.link, let url = URL(string: link) {
            router.navigateToArticle(with: url)
        } else {
            router.presentAlert(
                alertViewModel: AlertViewModel(
                    title: "feed_items_list_broken_article_link_title".localized(),
                    message: nil,
                    actions: [AlertActionViewModel(title: "OK", action: nil)]
                )
            )
        }
    }
    
    func onPullToRefresh() {
        pullToRefreshSubject.send()
    }
}
