//
//  FeedItemModel+CoreDataProperties.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 22.04.2024..
//
//

import Foundation
import CoreData


extension FeedItemModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedItemModel> {
        return NSFetchRequest<FeedItemModel>(entityName: "FeedItemModel")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var link: String?
    @NSManaged public var title: String?
    @NSManaged public var datePublished: Date?

}

extension FeedItemModel : Identifiable {

}
