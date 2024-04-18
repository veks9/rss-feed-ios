//
//  AppRootViewController.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

final class AppRootViewController: UINavigationController {
    private let viewModel: AppRootViewModel
    
    init(viewModel: AppRootViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        startAppFlow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
