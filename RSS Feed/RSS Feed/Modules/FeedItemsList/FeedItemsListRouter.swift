//
//  FeedItemsListRouter.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 20.04.2024..
//

import UIKit

protocol FeedItemsListRouting {
    var viewController: FeedItemsListViewController? { get set }
}

final class FeedItemsListRouter: FeedItemsListRouting {
    weak var viewController: FeedItemsListViewController?
}
