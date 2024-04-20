//
//  FeedListCellType.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import Foundation

enum FeedListCellType {
    case feed(FeedCellViewModel)
    case empty(EmptyCellViewModel)
}

extension FeedListCellType: Hashable  {
    static func == (lhs: FeedListCellType, rhs: FeedListCellType) -> Bool {
        switch (lhs, rhs) {
        case (.feed(let lhsViewModel), .feed(let rhsViewModel)):
            return lhsViewModel.id == rhsViewModel.id && lhsViewModel.isFavorited == rhsViewModel.isFavorited
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .feed(let cellViewModel):
            hasher.combine("feed-\(cellViewModel.id)")
        case .empty:
            hasher.combine("emptyCell")
        }
    }
}
