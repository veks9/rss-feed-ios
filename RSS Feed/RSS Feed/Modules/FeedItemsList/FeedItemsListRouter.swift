//
//  FeedItemsListRouter.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 20.04.2024..
//

import UIKit
import SafariServices

protocol FeedItemsListRouting: Alertable {
    var viewController: FeedItemsListViewController? { get set }
    
    func navigateToArticle(with url: URL)
}

final class FeedItemsListRouter: FeedItemsListRouting {
    weak var viewController: FeedItemsListViewController?
    
    func navigateToArticle(with url: URL) {
        let configuration = SFSafariViewController.Configuration()

        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        viewController?.present(safariViewController, animated: true)
    }
}
