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
    func getFeeds(for feedUrls: [URL]) -> AnyPublisher<[RSSFeed], ParserError>
}

final class FeedService: FeedServicing {
    
    static let shared = FeedService()
    
    private let rssParser: RSSParsing
    
    private init(rssParser: RSSParsing = RSSParser()) {
        self.rssParser = rssParser
    }
    
    func getFeeds(for feedUrls: [URL]) -> AnyPublisher<[RSSFeed], ParserError> {
        Publishers.CombineLatestArray(
            feedUrls.map({ feedUrl in
                rssParser.parse(url: feedUrl)
                    .compactMap { $0 }
            })
        )
    }
}
