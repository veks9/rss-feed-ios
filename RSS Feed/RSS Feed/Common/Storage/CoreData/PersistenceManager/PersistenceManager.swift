//
//  PersistenceManager.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 21.04.2024..
//

import Foundation
import CoreData
import Combine

protocol PersistenceManaging {
    var feedsChanged: AnyPublisher<Void, Never> { get }
    var feedsBackgroundContext: NSManagedObjectContext { get }

    func saveFeedsIfHasChanges() throws
}

final class PersistenceManager: PersistenceManaging {
    static let shared = PersistenceManager()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let feedsChangedSubject = PassthroughSubject<Void, Never>()

    var feedsChanged: AnyPublisher<Void, Never> {
        feedsChangedSubject.eraseToAnyPublisher()
    }

    lazy var feedsBackgroundContext = persistentContainer.newBackgroundContext()

    private init() {}

    func saveFeedsIfHasChanges() throws {
        if feedsBackgroundContext.hasChanges {
            try feedsBackgroundContext.save()
            feedsChangedSubject.send()
        }
    }
}
