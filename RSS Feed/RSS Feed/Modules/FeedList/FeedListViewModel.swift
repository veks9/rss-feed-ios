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
    var dataSource: AnyPublisher<[FeedListSection], Never> { get }
    var handleAddingFeed: AnyPublisher<Void, Never> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    var handleDeletingFeed: AnyPublisher<Void, Never> { get }
    var handleRowSelect: AnyPublisher<Void, Never> { get }
    
    func onViewDidLoad()
    func onRowSelect(with cellViewModel: FeedCellViewModel)
    func onAddFeedTap()
    func onSwipeToDelete(with cellViewModel: FeedCellViewModel)
}

final class FeedListViewModel: FeedListViewModeling {
    
    private let router: FeedListRouting
    private let feedService: FeedServicing
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let itemForDeletionIdSubject = PassthroughSubject<String, Never>()
    private let itemForInsertionUrlSubject = PassthroughSubject<URL, Never>()
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let selectedRowIdSubject = PassthroughSubject<String, Never>()
    
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
                guard let self else { return [
                    FeedListSection(
                        section: .standard,
                        items: [
                            FeedListCellType.empty(
                                EmptyCellViewModel(
                                    id: "emptyCell",
                                    image: Assets.plus.systemImage,
                                    descriptionText: "feed_list_empty_description".localized()
                                )
                            )
                        ]
                    )
                ] }
                return createSections(from: models)
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
                        return Empty<FeedModel, Never>(completeImmediately: false).eraseToAnyPublisher()
                    }
                    .ignoreFailure()
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
    
    var handleRowSelect: AnyPublisher<Void, Never> {
        selectedRowIdSubject
            .withLatestFrom(models) { ($0, $1) }
            .handleEvents(receiveOutput: { [weak self] selectedRowId, models in
                guard let self else { return }
                if let model = models.first(where: { $0.id == selectedRowId }), let id = model.id {
                    router.navigateToFeedItemsList(context: FeedItemsListContext(parentFeedId: id))
                }
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
    
    private func createSections(from models: [FeedModel]) -> [FeedListSection] {
        let emptyCell = FeedListCellType.empty(
            EmptyCellViewModel(
                id: "emptyCell",
                image: Assets.plus.systemImage,
                descriptionText: "feed_list_empty_description".localized()
            )
        )
        
        let cells = getCells(from: models.filter { !$0.isFavorited })
        let favoritedCells = getCells(from: models.filter { $0.isFavorited })
        
        if models.isEmpty {
            return [FeedListSection(section: .standard, items: [emptyCell])]
        } else {
            var sections = [FeedListSection]()
            if favoritedCells.isEmpty {
                sections.append(FeedListSection(section: .standard, items: cells))
            } else {
                sections.append(FeedListSection(section: .favorited, items: favoritedCells))
                cells.isEmpty ? () : sections.append(FeedListSection(section: .feeds, items: cells))
            }

            return sections
        }
    }
    
    private func getCells(from models: [FeedModel]) -> [FeedListCellType] {
        var dataSource: [FeedListCellType] = []
        dataSource.append(contentsOf: getFeedCells(from: models))
        
        return dataSource
    }
    
    private func getFeedCells(from models: [FeedModel]) -> [FeedListCellType] {
        models.compactMap { feed in
            .feed(
                FeedCellViewModel(
                    id: feed.id ?? UUID().uuidString,
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
        selectedRowIdSubject.send(cellViewModel.id)
    }
    
    func onAddFeedTap() {
        router.presentAddNewFeedAlert { [weak self] feedUrl in
            self?.addFeed(with: feedUrl)
        }
    }
    
    func onSwipeToDelete(with cellViewModel: FeedCellViewModel) {
        itemForDeletionIdSubject.send(cellViewModel.id)
    }
}
