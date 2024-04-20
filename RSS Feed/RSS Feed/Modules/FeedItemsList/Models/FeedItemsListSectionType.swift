//
//  FeedItemsListSectionType.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 20.04.2024..
//

import Foundation

enum FeedItemsListSectionType {
    case standard
}

extension FeedItemsListSectionType: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .standard:
            hasher.combine("standard")
        }
    }

    static func == (lhs: FeedItemsListSectionType, rhs: FeedItemsListSectionType) -> Bool {
        switch (lhs, rhs) {
        case (.standard, .standard):
            return true
        }
    }
}
