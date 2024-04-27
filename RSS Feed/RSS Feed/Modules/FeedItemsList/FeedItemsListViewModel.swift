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
    var notificationsImage: AnyPublisher<UIImage?, Never> { get }
    var markAsFavoriteImage: AnyPublisher<UIImage?, Never> { get }
    var dataSource: AnyPublisher<[FeedItemsListSection], Never> { get }
    
    func onViewDidLoad()
    func onNotificationsIconTap()
    func onMarkAsFavoriteIconTap()
    func onRowSelect(with cellViewModel: FeedItemCellViewModel)
    func onPullToRefresh()
}

final class FeedItemsListViewModel: FeedItemsListViewModeling {
    
    private let context: FeedItemsListContext
    private let router: FeedItemsListRouting
    private let feedService: FeedServicing
    private var cancellables = Set<AnyCancellable>()
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let pullToRefreshSubject = PassthroughSubject<Void, Never>()
    private let favoritesIconSelectedSubject = PassthroughSubject<Void, Never>()
    private let notificationsIconSelectedSubject = PassthroughSubject<Void, Never>()
    
    init(
        context: FeedItemsListContext,
        router: FeedItemsListRouting,
        feedService: FeedServicing = FeedService.shared
    ) {
        self.context = context
        self.router = router
        self.feedService = feedService
        
        observe()
    }
    
    // MARK: - Internal properties
    
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
                .catch({ [weak self] error in
                    self?.router.presentAlert(
                        alertViewModel: AlertViewModel(
                            title: "feed_items_list_fetching_error".localized(),
                            message: nil,
                            actions: [AlertActionViewModel(title: "OK", action: nil)]
                        )
                    )
                    return Empty<FeedModel, Never>(completeImmediately: false)
                })
                .ignoreFailure()
        }
        .share(replay: 1)
        .eraseToAnyPublisher()
    }()
    
    var notificationsImage: AnyPublisher<UIImage?, Never> {
        Publishers.CombineLatest(
            viewDidLoadSubject,
            parentFeed
        )
        .map { _, parentFeed in
            parentFeed.isNotificationsEnabled ? Assets.bellFill.systemImage : Assets.bell.systemImage
        }
        .eraseToAnyPublisher()
    }
    
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
                guard let self else { return [] }
                return createSections(from: parentFeed.itemsArray)
            })
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
    
    // MARK: - Private functions
    
    private func observe() {
        notificationsIconSelectedSubject
            .withLatestFrom(parentFeed)
            .flatMapLatest({ [feedService] parentFeed in
                parentFeed.isNotificationsEnabled.toggle()
                return feedService.updateFeed(feed: parentFeed)
                    .catch { [weak self] error in
                        self?.router.presentAlert(
                            alertViewModel: AlertViewModel(
                                title: "feed_items_list_notifications_error".localized(),
                                message: nil,
                                actions: [AlertActionViewModel(title: "OK", action: nil)]
                            )
                        )
                        return Empty<FeedModel, Never>(completeImmediately: false).eraseToAnyPublisher()
                    }
                    .ignoreFailure()
            })
            .sink { _ in }
            .store(in: &cancellables)
        
        favoritesIconSelectedSubject
            .withLatestFrom(parentFeed)
            .flatMapLatest({ [feedService] parentFeed in
                parentFeed.isFavorited.toggle()
                return feedService.updateFeed(feed: parentFeed)
                    .catch { [weak self] error in
                        self?.router.presentAlert(
                            alertViewModel: AlertViewModel(
                                title: "feed_items_list_favoriting_error".localized(),
                                message: nil,
                                actions: [AlertActionViewModel(title: "OK", action: nil)]
                            )
                        )
                        return Empty<FeedModel, Never>(completeImmediately: false).eraseToAnyPublisher()
                    }
                    .ignoreFailure()
            })
            .sink { _ in }
            .store(in: &cancellables)
        
        pullToRefreshSubject
            .flatMapLatest { [feedService, context] _ in
                feedService.fetchFeedAndUpdateLocal(for: URL(string: context.parentFeedId)!)
                    .catch({ [weak self] error in
                        self?.router.presentAlert(
                            alertViewModel: AlertViewModel(
                                title: "feed_items_list_fetching_error".localized(),
                                message: nil,
                                actions: [AlertActionViewModel(title: "OK", action: nil)]
                            )
                        )
                        return Empty<FeedModel, Never>(completeImmediately: false)
                    })
                    .ignoreFailure()
            }
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    private func createSections(from models: [FeedItemModel]) -> [FeedItemsListSection] {
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
    
    func onNotificationsIconTap() {
        notificationsIconSelectedSubject.send()
    }
    
    func onMarkAsFavoriteIconTap() {
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
