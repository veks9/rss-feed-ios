//
//  UICollectionView+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

extension UICollectionView {
    func dequeueCellAtIndexPath<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withReuseIdentifier: T.identity, for: indexPath) as? T {
            return cell
        } else {
            fatalError("cell with \"\(T.identity)\" identifier is not registered!")
        }
    }
}
