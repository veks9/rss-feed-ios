//
//  FeedListViewModel.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import Foundation
import Combine

protocol FeedListViewModeling {
    func onViewDidLoad()
}

final class FeedListViewModel: FeedListViewModeling {

    private let router: FeedListRouting
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    
    init(router: FeedListRouting) {
        self.router = router
    }
}

// MARK: - Internal functions

extension FeedListViewModel {
    func onViewDidLoad() {
        viewDidLoadSubject.send()
    }
}
