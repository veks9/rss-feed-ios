//
//  FeedListViewController.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

final class FeedListViewController: UIViewController {
    
    private let viewModel: FeedListViewModeling
    
    // MARK: - Views
    
    // MARK: - Lifecycle
    
    init(viewModel: FeedListViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleView()
        addSubviews()
        setConstraints()
        observe()
        
        viewModel.onViewDidLoad()
    }
    
    private func styleView() {
        
    }
    
    private func addSubviews() {
    }
    
    private func setConstraints() {
    }
    
    private func observe() {
    }
}
