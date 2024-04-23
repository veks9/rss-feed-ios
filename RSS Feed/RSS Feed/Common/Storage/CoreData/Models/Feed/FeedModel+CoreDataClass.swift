//
//  FeedModel+CoreDataClass.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 21.04.2024..
//
//

import Foundation
import CoreData
import FeedKit

public class FeedModel: NSManagedObject {
    convenience init(
        id: String,
        rssUrl: String,
        title: String? = nil,
        feedDescription: String? = nil,
        imageUrl: String? = nil,
        updatedAt: Date,
        items: NSSet? = nil,
        isFavorited: Bool
    ) {
        self.init(context: PersistenceManager.shared.feedsBackgroundContext)
        self.id = id
        self.rssUrl = rssUrl
        self.title = title
        self.feedDescription = feedDescription
        self.imageUrl = imageUrl
        self.updatedAt = updatedAt
        self.items = items
        self.isFavorited = isFavorited
    }
    
    convenience init(
        from model: RSSFeed,
        rssUrl: String,
        isFavorited: Bool
    ) {
        self.init(context: PersistenceManager.shared.feedsBackgroundContext)
        self.id = rssUrl
        self.rssUrl = rssUrl
        self.title = model.title
        self.feedDescription = model.description
        self.imageUrl = model.image?.url
        self.updatedAt = Date()
        self.items = NSSet(array: model.items?.map { FeedItemModel(from: $0) } ?? [])
        self.isFavorited = isFavorited
    }
    
    func update(with model: FeedModel) {
        self.id = model.id
        self.rssUrl = model.rssUrl
        self.title = model.title
        self.feedDescription = model.feedDescription
        self.imageUrl = model.imageUrl
        self.updatedAt = model.updatedAt
        self.items = model.items
        self.isFavorited = model.isFavorited
    }
    
    func update(with model: RSSFeed) {
        self.title = model.title
        self.feedDescription = model.description
        self.imageUrl = model.image?.url
        self.updatedAt = Date()
        self.items = NSSet(array: model.items?.map { FeedItemModel(from: $0) } ?? [])
        self.isFavorited = isFavorited
    }
}
