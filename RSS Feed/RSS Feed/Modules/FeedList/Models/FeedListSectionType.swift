//
//  FeedListSectionType.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import Foundation

enum FeedListSectionType {
    case standard
}

extension FeedListSectionType: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .standard:
            hasher.combine("standard")
        }
    }

    static func == (lhs: FeedListSectionType, rhs: FeedListSectionType) -> Bool {
        switch (lhs, rhs) {
        case (.standard, .standard):
            return true
        }
    }
}
