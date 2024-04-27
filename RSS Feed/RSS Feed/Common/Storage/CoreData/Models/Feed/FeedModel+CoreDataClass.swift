//
//  FeedModel+CoreDataClass.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 26.04.2024..
//
//

import Foundation
import CoreData
import FeedKit

public class FeedModel: NSManagedObject {
    convenience init(
        from model: RSSFeed,
        rssUrl: String,
        isFavorited: Bool = false,
        isNotificationsEnabled: Bool = false
    ) {
        self.init(context: PersistenceManager.shared.feedsBackgroundContext)
        self.id = rssUrl
        self.rssUrl = rssUrl
        self.title = model.title
        self.feedDescription = model.description
        self.imageUrl = model.image?.url
        self.updatedAt = Date()
        self.addToItems(NSSet(array: model.items?.map { FeedItemModel(from: $0, parentFeed: self) } ?? []))
        self.isFavorited = isFavorited
        self.isNotificationsEnabled = isNotificationsEnabled
    }
    
    func update(with model: FeedModel) {
        self.id = model.id
        self.rssUrl = model.rssUrl
        self.title = model.title
        self.feedDescription = model.feedDescription
        self.imageUrl = model.imageUrl
        self.updatedAt = model.updatedAt
        self.addToItems(model.items ?? NSSet())
        self.isFavorited = model.isFavorited
        self.isNotificationsEnabled = model.isNotificationsEnabled
    }
    
    func update(with model: RSSFeed) {
        self.title = model.title
        self.feedDescription = model.description
        self.imageUrl = model.image?.url
        self.updatedAt = Date()
        self.addToItems(NSSet(array: model.items?.map { FeedItemModel(from: $0, parentFeed: self) } ?? []))
        self.isFavorited = isFavorited
        self.isNotificationsEnabled = isNotificationsEnabled
    }
}
