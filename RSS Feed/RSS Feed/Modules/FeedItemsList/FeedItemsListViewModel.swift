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
    var navigationTitle: String { get }
    var markAsFavoriteImage: AnyPublisher<UIImage?, Never> { get }
    var dataSource: AnyPublisher<[FeedItemsListSection], Never> { get }
    
    func onViewDidLoad()
    func onMarkAsFavoriteTap()
    func onRowSelect(with cellViewModel: FeedItemCellViewModel)
    func onPullToRefresh()
}

final class FeedItemsListViewModel: FeedItemsListViewModeling {
    
    private let context: FeedItemsListContext
    private let router: FeedItemsListRouting
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let refreshSubject = PassthroughSubject<Void, Never>()
    private lazy var isFavoritesIconSelected = CurrentValueSubject<Bool, Never>(false)
    
    init(
        context: FeedItemsListContext,
        router: FeedItemsListRouting
    ) {
        self.context = context
        self.router = router
    }
    
    var navigationTitle: String {
        "BBC news"
    }
    
    var markAsFavoriteImage: AnyPublisher<UIImage?, Never> {
        Publishers.CombineLatest(
            viewDidLoadSubject,
            isFavoritesIconSelected
        )
        .map { _, isFavoritesIconSelected in
            isFavoritesIconSelected ? Assets.starFill.systemImage : Assets.star.systemImage
        }
        .eraseToAnyPublisher()
    }
    
    lazy var dataSource: AnyPublisher<[FeedItemsListSection], Never> = {
        Publishers.CombineLatest(
            viewDidLoadSubject,
            refreshSubject.prepend(())
        )
        .flatMap { _, _ in
            Just([
                FeedItemsListSection(
                    section: .standard,
                    items: [
                        .feedItem(FeedItemCellViewModel(id: "0", title: "Dubai airport chaos as Gulf reels from deadly storms", description: "The airport, which serves as a major hub for connecting flights to every continent, warns \"recovery will take some time\".", imageUrl: "https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/18C1/production/_133173360_gettyimages-2147872587.jpg")),
                        .feedItem(FeedItemCellViewModel(id: "1", title: "Dubai airport chaos as Gulf reels from deadly storms", description: "The airport, which serves as a major hub for connecting flights to every continent, warns \"recovery will take some time\".", imageUrl: "https://ichef.bbci.co.uk/ace/standard/240/cpsprodpb/18C1/production/_133173360_gettyimages-2147872587.jpg"))
                    ]
                )
            ])
        }
        .share(replay: 1)
        .eraseToAnyPublisher()
    }()
}

// MARK: - Internal functions

extension FeedItemsListViewModel {
    func onViewDidLoad() {
        viewDidLoadSubject.send()
    }
    
    func onMarkAsFavoriteTap() {
        isFavoritesIconSelected.send(!isFavoritesIconSelected.value)
    }
    
    func onRowSelect(with cellViewModel: FeedItemCellViewModel) {
    }
    
    func onPullToRefresh() {
        refreshSubject.send()
    }
}
