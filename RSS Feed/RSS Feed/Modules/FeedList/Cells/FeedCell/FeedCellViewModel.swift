//
//  FeedCellViewModel.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

final class FeedCellViewModel {
    let id: String
    let title: String
    let description: String?
    let imageUrl: String?
    let isFavorited: Bool

    init(
        id: String,
        title: String,
        description: String,
        imageUrl: String?,
        isFavorited: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.isFavorited = isFavorited
    }
}
