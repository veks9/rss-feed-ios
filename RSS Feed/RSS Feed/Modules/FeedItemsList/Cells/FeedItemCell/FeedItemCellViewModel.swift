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
    let datePublished: Date?
    let link: String?
    
    init(
        id: String,
        title: String,
        description: String?,
        imageUrl: String?,
        datePublished: Date?,
        link: String?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.datePublished = datePublished
        self.link = link
    }
}
