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
    
    func onViewDidLoad()
    func onRowSelect()
    func onAddFeedTap()
    func onShowFavoritesTap()
}

final class FeedListViewModel: FeedListViewModeling {

    private let router: FeedListRouting
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let isFavoritesIconSelected = CurrentValueSubject<Bool, Never>(false)
    
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
}

// MARK: - Internal functions

extension FeedListViewModel {
    func onViewDidLoad() {
        viewDidLoadSubject.send()
    }
    
    func onRowSelect() {}
    
    func onAddFeedTap() {
    }
    
    func onShowFavoritesTap() {
        isFavoritesIconSelected.send(!isFavoritesIconSelected.value)
    }
}
