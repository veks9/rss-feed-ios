//
//  FeedItemsListCellType.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 20.04.2024..
//

import Foundation

enum FeedItemsListCellType {
    case feedItem(FeedItemCellViewModel)
    case empty(EmptyCellViewModel)
}

extension FeedItemsListCellType: Hashable  {
    static func == (lhs: FeedItemsListCellType, rhs: FeedItemsListCellType) -> Bool {
        switch (lhs, rhs) {
        case (.feedItem(let lhsViewModel), .feedItem(let rhsViewModel)):
            return lhsViewModel.id == rhsViewModel.id
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .feedItem(let cellViewModel):
            hasher.combine("feedItem-\(cellViewModel.id)")
        case .empty:
            hasher.combine("emptyCell")
        }
    }
}
