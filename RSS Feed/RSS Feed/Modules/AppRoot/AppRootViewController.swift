//
//  AppRootViewController.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

final class AppRootViewController: UINavigationController {
    private let viewModel: AppRootViewModel
    
    // MARK: - Lifecycle
    
    init(viewModel: AppRootViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        startAppFlow()
        styleView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private functions
    
    private func styleView() {
        navigationBar.tintColor = .black
    }
    
    private func startAppFlow() {
        navigateToHome()
    }
    
    // MARK: - Navigation
    
    private func navigateToHome() {
        let router = FeedListRouter()
        let viewModel = FeedListViewModel(router: router)
        let viewController = FeedListViewController(viewModel: viewModel)
        router.viewController = viewController
        
        setViewControllers([viewController], animated: false)
    }
    
    private func navigateToFeedItems(for parentFeedId: String) {
        let feedListRouter = FeedListRouter()
        let feedListViewModel = FeedListViewModel(router: feedListRouter)
        let feedListViewController = FeedListViewController(viewModel: feedListViewModel)
        feedListRouter.viewController = feedListViewController
        
        let feedItemsListRouter = FeedItemsListRouter()
        let feedItemsListViewModel = FeedItemsListViewModel(
            context: FeedItemsListContext(parentFeedId: parentFeedId),
            router: feedItemsListRouter
        )
        let feedItemsListViewController = FeedItemsListViewController(viewModel: feedItemsListViewModel)
        feedItemsListRouter.viewController = feedItemsListViewController
        
        setViewControllers([feedListViewController, feedItemsListViewController], animated: false)
    }
}

// MARK: - Internal functions

extension AppRootViewController {
    func handleReceivedNotification(response: UNNotificationResponse) {
        var pendingNotificationData = [String: String]()
        let userInfo = response.notification.request.content.userInfo
        userInfo.forEach { key, value in
           guard let keyString = key as? String, let valueString = value as? String else {
               return
           }
           pendingNotificationData[keyString] = valueString
       }
       if let id = pendingNotificationData["id"] {
           navigateToFeedItems(for: id)
       }
    }
}
