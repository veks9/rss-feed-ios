//
//  Assets.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

enum Assets: String {
    
    case plus
    case star
    case starFill = "star.fill"
    case chevronRight = "chevron.right"
    case rssPlaceholder = "rss-placeholder"
    case trash
    
    var image: UIImage? {
        UIImage(named: rawValue)
    }
    
    var systemImage: UIImage? {
        UIImage(systemName: rawValue)
    }
}
