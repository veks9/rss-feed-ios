//
//  UserDefaultsService.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 21.04.2024..
//

import Foundation
import Combine

protocol UserDefaultsServicing {
    var feedUrls: AnyPublisher<[String], Never> { get }
    
    func setFeedUrls(_ feedUrls: [String])
}

final class UserDefaultsService: UserDefaultsServicing {

    static let shared = UserDefaultsService()

    private let userDefaults = UserDefaults.standard
    
    static let feedUrlsKey = "feedUrls"
    
    lazy var feedUrls: AnyPublisher<[String], Never> = {
        userDefaults
            .publisher(for: \.feedUrls)
            .removeDuplicates()
            .share(replay: 1)
            .eraseToAnyPublisher()
    }()
    
    private init() {}

    func setFeedUrls(_ feedUrls: [String]) {
        userDefaults.feedUrls = feedUrls
    }

    func clearUserDefaults() {
        userDefaults.removeObject(forKey: UserDefaultsService.feedUrlsKey)
    }
}

extension UserDefaults {
    @objc var feedUrls: [String] {
        get {
            return array(forKey: UserDefaultsService.feedUrlsKey) as? [String] ?? []
        }
        set {
            set(newValue, forKey: UserDefaultsService.feedUrlsKey)
        }
    }
}
