//
//  FeedModel+CoreDataProperties.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 21.04.2024..
//
//

import Foundation
import CoreData


extension FeedModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedModel> {
        return NSFetchRequest<FeedModel>(entityName: "FeedModel")
    }

    @NSManaged public var feedDescription: String?
    @NSManaged public var id: String
    @NSManaged public var imageUrl: String?
    @NSManaged public var isFavorited: Bool
    @NSManaged public var rssUrl: String
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Date
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension FeedModel {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: FeedItemModel)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: FeedItemModel)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension FeedModel : Identifiable {

}
