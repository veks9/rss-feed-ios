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
    // TODO: - remove showFavorites image if unused in future
    var showFavoritesImage: AnyPublisher<UIImage?, Never> { get }
    var dataSource: AnyPublisher<[FeedListSection], Never> { get }
    var handleAddingFeed: AnyPublisher<Void, Never> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    var handleDeletingFeed: AnyPublisher<Void, Never> { get }
    var handleFavoritingFeed: AnyPublisher<Void, Never> { get }
    
    func onViewDidLoad()
    func onRowSelect(with cellViewModel: FeedCellViewModel)
    func onAddFeedTap()
    // TODO: - remove onShowFavoritesTap if unused in future
    func onShowFavoritesTap()
    func onSwipeToDelete(with cellViewModel: FeedCellViewModel)
    func onMarkFeedFavorite(with cellViewModel: FeedCellViewModel)
}

final class FeedListViewModel: FeedListViewModeling {
    
    private let router: FeedListRouting
    private let feedService: FeedServicing
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let isFavoritesIconSelected = CurrentValueSubject<Bool, Never>(false)
    private let itemForDeletionIdSubject = PassthroughSubject<String, Never>()
    private let itemForInsertionUrlSubject = PassthroughSubject<URL, Never>()
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let itemForFavoritingIdSubject = PassthroughSubject<String, Never>()
    
    init(
        router: FeedListRouting,
        feedService: FeedServicing = FeedService.shared
    ) {
        self.router = router
        self.feedService = feedService
    }
    
    var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
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
    
    lazy var models: AnyPublisher<[FeedModel], Never> = {
        Publishers.CombineLatest(
            viewDidLoadSubject,
            feedService.feedsChanged.prepend(())
        )
        .handleEvents(receiveOutput: { [weak self] _ in
            self?.isLoadingSubject.send(true)
        })
            .flatMap { [feedService] _ in
                feedService.getAllFeeds()
                    .catch { [weak self] _ in
                        self?.router.presentAlert(
                            alertViewModel: AlertViewModel(
                                title: "feed_list_feed_fetching_failure".localized(),
                                message: nil,
                                actions: [AlertActionViewModel(title: "OK", action: nil)]
                            )
                        )
                        self?.isLoadingSubject.send(false)
                        return Empty<[FeedModel], Never>(completeImmediately: false).eraseToAnyPublisher()
                    }
                    .ignoreFailure()
            }
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
    
    lazy var dataSource: AnyPublisher<[FeedListSection], Never> = {
        models
            .map { [weak self] models in
                guard let self else { return [] }
                return createFeedCells(from: models)
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(false)
            })
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
    
    var handleAddingFeed: AnyPublisher<Void, Never> {
        itemForInsertionUrlSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(true)
            })
            .flatMap({ [feedService] itemForInsertionUrl in
                feedService.fetchFeed(for: itemForInsertionUrl)
                    .receive(on: DispatchQueue.main)
                    .catch { [weak self] _ in
                        self?.isLoadingSubject.send(false)
                        self?.router.presentAlert(
                            alertViewModel: AlertViewModel(
                                title: "feed_list_feed_fetching_failure".localized(),
                                message: nil,
                                actions: [AlertActionViewModel(title: "OK", action: nil)]
                            )
                        )
                        return Empty<RSSFeed?, Never>(completeImmediately: false).eraseToAnyPublisher()
                    }
                    .ignoreFailure()
                    .map { ($0, itemForInsertionUrl) }
            })
            .withLatestFrom(models) { ($0.0, $0.1, $1) }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] newFeed, itemForInsertionUrl, feeds in
                guard let self else { return }
                isLoadingSubject.send(false)
                if let newFeed = newFeed {
                    if feeds.contains(where: { $0.rssUrl == itemForInsertionUrl.absoluteString }) {
                        router.presentAlert(
                            alertViewModel: AlertViewModel(
                                title: "feed_list_feed_already_exists".localized(),
                                message: nil,
                                actions: [AlertActionViewModel(title: "OK", action: nil)]
                            )
                        )
                    } else {
                        feedService.createFeed(from: newFeed, rssUrl: itemForInsertionUrl.absoluteString)
                    }
                } else {
                    router.presentAlert(
                        alertViewModel: AlertViewModel(
                            title: "feed_list_feed_adding_failure".localized(),
                            message: nil,
                            actions: [AlertActionViewModel(title: "OK", action: nil)]
                        )
                    )
                }
            })
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    var handleDeletingFeed: AnyPublisher<Void, Never> {
        itemForDeletionIdSubject
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(true)
            })
            .flatMap { [feedService] itemForDeletionId in
                feedService.deleteFeed(with: itemForDeletionId)
                    .receive(on: DispatchQueue.main)
                    .catch { [weak self] _ in
                        self?.isLoadingSubject.send(false)
                        self?.router.presentAlert(
                            alertViewModel: AlertViewModel(
                                title: "feed_list_feed_deleting_failure".localized(),
                                message: nil,
                                actions: [AlertActionViewModel(title: "OK", action: nil)]
                            )
                        )
                        return Empty<FeedModel, Never>(completeImmediately: false).eraseToAnyPublisher()
                    }
                    .ignoreFailure()
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoadingSubject.send(false)
            })
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    var handleFavoritingFeed: AnyPublisher<Void, Never> {
        itemForFavoritingIdSubject
            .withLatestFrom(models) { ($0, $1) }
            .flatMap({ [weak self] id, models in
                guard let self, let model = models.first(where: { $0.id == id }) else { return Empty<FeedModel, Never>(completeImmediately: false).eraseToAnyPublisher() }
                model.isFavorited = !model.isFavorited
                return feedService.updateFeed(feed: model)
                    .receive(on: DispatchQueue.main)
                    .catch {[weak self] _ in
                        self?.router.presentAlert(
                            alertViewModel: AlertViewModel(
                                title: "feed_list_feed_favoriting_failure".localized(),
                                message: nil,
                                actions: [AlertActionViewModel(title: "OK", action: nil)]
                            )
                        )
                        return Empty<FeedModel, Never>(completeImmediately: false).eraseToAnyPublisher()
                    }
                    .ignoreFailure()
            })
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    private func addFeed(with urlString: String?) {
        if let urlString = urlString, let url = URL(string: urlString)  {
            itemForInsertionUrlSubject.send(url)
        } else {
            router.presentAlert(
                alertViewModel: AlertViewModel(
                    title: "feed_list_feed_fetching_failure".localized(),
                    message: nil,
                    actions: [AlertActionViewModel(title: "OK", action: nil)]
                )
            )
        }
    }
    
    private func createFeedCells(from models: [FeedModel]) -> [FeedListSection] {
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
    
    private func getCells(from models: [FeedModel]) -> [FeedListCellType] {
        var dataSource: [FeedListCellType] = []
        let cells = getFeedCells(from: models)
        dataSource.append(contentsOf: cells)
        
        return dataSource
    }
    
    private func getFeedCells(from models: [FeedModel]) -> [FeedListCellType] {
        models.map { feed in
            .feed(
                FeedCellViewModel(
                    id: feed.id,
                    title: feed.title ?? "[-]",
                    description: feed.feedDescription ?? "[-]",
                    imageUrl: feed.imageUrl,
                    isFavorited: feed.isFavorited
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
    
    func onMarkFeedFavorite(with cellViewModel: FeedCellViewModel) {
        itemForFavoritingIdSubject.send(cellViewModel.id)
    }
}
