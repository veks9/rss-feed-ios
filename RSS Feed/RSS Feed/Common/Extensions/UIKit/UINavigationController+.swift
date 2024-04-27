//
//  UINavigationController+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

extension UINavigationController {
    func setAppearance(backgroundColor: UIColor, tintColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = .clear
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.tintColor = tintColor
    }
}
