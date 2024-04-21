//
//  FeedListRouter.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

protocol FeedListRouting: Alertable {
    var viewController: FeedListViewController? { get set }
    
    func presentAddNewFeedAlert(onSubmit: @escaping (String?) -> ())
    func navigateToFeedItemsList(context: FeedItemsListContext)
}

final class FeedListRouter: FeedListRouting {
    weak var viewController: FeedListViewController?
    
    func presentAddNewFeedAlert(onSubmit: @escaping (String?) -> ()) {
        let alertViewController = UIAlertController(
            title: "feed_list_add_new_feed_title".localized(),
            message: nil,
            preferredStyle: .alert
        )
        alertViewController.addTextField { textField in
            textField.placeholder = "feed_list_add_new_feed_placeholder".localized()
        }
        
        let submitAction = UIAlertAction(
            title: "feed_list_add_new_feed_submit_button_title".localized(),
            style: .default
        ) { _ in
            if let textField = alertViewController.textFields?[safe: 0] {
                onSubmit(textField.text)
            }
        }
        let cancelAction = UIAlertAction(
            title: "feed_list_add_new_feed_cancel_button_title".localized(),
            style: .cancel
        )
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(submitAction)
        
        viewController?.present(alertViewController, animated: true)
    }
    
    func navigateToFeedItemsList(context: FeedItemsListContext) {
        let router = FeedItemsListRouter()
        let viewModel = FeedItemsListViewModel(context: context, router: router)
        let viewController = FeedItemsListViewController(viewModel: viewModel)
        router.viewController = viewController
        
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
