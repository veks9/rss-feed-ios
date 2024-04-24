//
//  FeedListSectionType.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import Foundation

enum FeedListSectionType {
    case standard
    case favorited
    case feeds
}

extension FeedListSectionType: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .standard:
            hasher.combine("standard")
        case .favorited:
            hasher.combine("favorited")
        case .feeds:
            hasher.combine("feeds")
        }
    }

    static func == (lhs: FeedListSectionType, rhs: FeedListSectionType) -> Bool {
        switch (lhs, rhs) {
        case (.standard, .standard):
            return true
        case (.favorited, .favorited):
            return true
        case (.feeds, .feeds):
            return true
        default:
            return false
        }
    }
}
