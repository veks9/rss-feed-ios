//
//  RSSParser.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 20.04.2024..
//

import Foundation
import Combine
import FeedKit

protocol RSSParsing {
    func parse(url: URL) -> Future<RSSFeed?, ParserError>
}

final class RSSParser: RSSParsing {
    func parse(url: URL) -> Future<RSSFeed?, ParserError> {
        Future { promise in
            FeedParser(URL: url).parseAsync { result in
                switch result {
                case .success(let success):
                    promise(.success(success.rssFeed))
                case .failure(let failure):
                    promise(.failure(failure))
                }
            }
        }
    }
}
