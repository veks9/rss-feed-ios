//
//  UIFont+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

extension UIFont {
    static func appFont(with size: CGFloat, weight: Weight = .regular) -> UIFont {
        UIFont(name: "SFProDisplay-\(weightString)", size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}

private extension UIFont.Weight {
    var weight: String {
        switch self {
        case .regular:
            return "Regular"
        case .medium:
            return "Medium"
        case .semibold:
            return "SemiBold"
        case .bold:
            return "Bold"
        default:
            return "Unknown"
        }
    }
}
