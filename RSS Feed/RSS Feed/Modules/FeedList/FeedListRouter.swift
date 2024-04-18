//
//  FeedListRouter.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

protocol FeedListRouting {
    var viewController: FeedListViewController? { get set }
}

final class FeedListRouter: FeedListRouting {
    weak var viewController: FeedListViewController?
}
