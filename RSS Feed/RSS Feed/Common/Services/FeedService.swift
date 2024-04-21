//
//  FeedService.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 21.04.2024..
//

import Foundation
import Combine
import FeedKit

protocol FeedServicing {
    var feedsChanged: AnyPublisher<Void, Never> { get }
    
    func fetchFeed(for feedUrl: URL) -> Future<RSSFeed?, ParserError>
    func createFeed(from model: RSSFeed, rssUrl: String) -> Future<FeedModel, Error>
    func updateFeed(feed: FeedModel) -> Future<FeedModel, Error>
    func deleteFeed(with feedId: String) -> Future<FeedModel, Error>
    func getAllFeeds() -> Future<[FeedModel], Error>
}

final class FeedService: FeedServicing {
    
    static let shared = FeedService()
    
    private let rssParser: RSSParsing
    private let persistenceManager: PersistenceManaging
    
    var feedsChanged: AnyPublisher<Void, Never> {
        persistenceManager.feedsChanged
    }
    
    private init(
        rssParser: RSSParsing = RSSParser(),
        persistenceManager: PersistenceManaging = PersistenceManager.shared
    ) {
        self.rssParser = rssParser
        self.persistenceManager = persistenceManager
    }
    
    func fetchFeed(for feedUrl: URL) -> Future<RSSFeed?, ParserError> {
        rssParser.parse(url: feedUrl)
    }
    
    func createFeed(from model: RSSFeed, rssUrl: String) -> Future<FeedModel, Error> {
        Future<FeedModel, Error> { [weak self] promise in
            guard let self else { return }
            persistenceManager.feedsBackgroundContext.perform { [weak self] in
                guard let self else { return }
                let feed = FeedModel(from: model, rssUrl: rssUrl, isFavorited: false)
                do {
                    try persistenceManager.saveFeedsIfHasChanges()
                    promise(.success(feed))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    func updateFeed(feed: FeedModel) -> Future<FeedModel, Error> {
        Future<FeedModel, Error> { [weak self] promise in
            guard let self else { return }
            persistenceManager.feedsBackgroundContext.perform { [weak self] in
                guard let self else { return }
                do {
                    let request = FeedModel.fetchRequest()
                    let feeds = try persistenceManager.feedsBackgroundContext.fetch(request)
                    let objectToEdit = feeds.first(where: { $0.id == feed.id })
                    objectToEdit?.update(with: feed)
                    try persistenceManager.saveFeedsIfHasChanges()
                    promise(.success(feed))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    func deleteFeed(with feedId: String) -> Future<FeedModel, Error> {
        Future<FeedModel, Error> { [weak self] promise in
            guard let self else { return }
            persistenceManager.feedsBackgroundContext.perform { [weak self] in
                guard let self else { return }
                let request = FeedModel.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", feedId)
                do {
                    let objectToDelete = try persistenceManager.feedsBackgroundContext.fetch(request)[safe: 0]
                    guard let objectToDelete = objectToDelete else { return }
                    persistenceManager.feedsBackgroundContext.delete(objectToDelete)
                    try persistenceManager.saveFeedsIfHasChanges()
                    promise(.success(objectToDelete))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    func getAllFeeds() -> Future<[FeedModel], Error> {
        Future<[FeedModel], Error> { [weak self] promise in
            guard let self else { return }
            persistenceManager.feedsBackgroundContext.perform { [weak self] in
                guard let self else { return }
                do {
                    let request = FeedModel.fetchRequest()
                    let feeds = try persistenceManager.feedsBackgroundContext.fetch(request)
                    promise(.success(feeds))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
