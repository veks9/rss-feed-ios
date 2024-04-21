//
//  UIView+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

extension UIView: Identifiable {
    static var identity: String {
        String(describing: self)
    }
}
