//
//  Collection+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
