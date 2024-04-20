//
//  FeedItemCellViewModel.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 20.04.2024..
//

import Foundation

final class FeedItemCellViewModel {
    let id: String
    let title: String
    let description: String?
    let imageUrl: String?

    init(
        id: String,
        title: String,
        description: String,
        imageUrl: String?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
    }
}
