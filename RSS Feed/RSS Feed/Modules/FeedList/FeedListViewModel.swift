//
//  FeedListViewModel.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit
import Combine
import CombineExt

protocol FeedListViewModeling {
    var showFavoritesImage: AnyPublisher<UIImage?, Never> { get }
    var dataSource: AnyPublisher<[FeedListSection], Never> { get }
    
    func onViewDidLoad()
    func onRowSelect(with cellViewModel: FeedCellViewModel)
    func onAddFeedTap()
    func onShowFavoritesTap()
    func onSwipeToDelete(with cellViewModel: FeedCellViewModel)
}

final class FeedListViewModel: FeedListViewModeling {
    
    private let router: FeedListRouting
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let isFavoritesIconSelected = CurrentValueSubject<Bool, Never>(false)
    private let itemForDeletionIdSubject = PassthroughSubject<String, Never>()
    
    init(router: FeedListRouting) {
        self.router = router
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
    
    lazy var dataSource: AnyPublisher<[FeedListSection], Never> = {
        viewDidLoadSubject
            .flatMapLatest { _ in
                Just([
                    FeedListSection(
                        section: .standard,
                        items: [
                            .feed(FeedCellViewModel(id: "0", title: "BBC News", description: "BBC News", imageUrl: nil, isFavorited: false)),
                            .feed(FeedCellViewModel(id: "1", title: "NY Times News", description: "NY Times News World", imageUrl: "https://static01.nyt.com/images/misc/NYT_logo_rss_250x40.png", isFavorited: false))
                        ]
                    )
                ])
            }
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
}

// MARK: - Internal functions

extension FeedListViewModel {
    func onViewDidLoad() {
        viewDidLoadSubject.send()
    }
    
    func onRowSelect(with cellViewModel: FeedCellViewModel) {
        
    }
    
    func onAddFeedTap() {
        router.presentAddNewFeedAlert { feedUrl in }
    }
    
    func onShowFavoritesTap() {
        isFavoritesIconSelected.send(!isFavoritesIconSelected.value)
    }
    
    func onSwipeToDelete(with cellViewModel: FeedCellViewModel) {
        itemForDeletionIdSubject.send(cellViewModel.id)
    }
}
