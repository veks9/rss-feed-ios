//
//  FeedItemModel+CoreDataClass.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 22.04.2024..
//
//

import Foundation
import CoreData
import FeedKit

public class FeedItemModel: NSManagedObject {
    convenience init(
        id: String,
        title: String? = nil,
        itemDescription: String? = nil,
        imageUrl: String? = nil,
        link: String? = nil,
        datePublished: Date? = nil
    ) {
        self.init(context: PersistenceManager.shared.feedsBackgroundContext)
        self.id = id
        self.title = title
        self.itemDescription = itemDescription
        self.imageUrl = imageUrl
        self.link = link
        self.datePublished = datePublished
    }
    
    convenience init(from model: RSSFeedItem) {
        self.init(context: PersistenceManager.shared.feedsBackgroundContext)
        self.id = model.guid?.value ?? UUID().uuidString
        self.title = model.title
        self.itemDescription = model.description
        self.imageUrl = model.media?.mediaThumbnails?.first?.attributes?.url
        self.link = model.link
        self.datePublished = model.pubDate
    }
}
