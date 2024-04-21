//
//  UITableView+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

extension UITableView {
    func dequeueCellAtIndexPath<T: UITableViewCell>(indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withIdentifier: T.identity, for: indexPath) as? T {
            return cell
        } else {
            fatalError("cell with \"\(T.identity)\" identifier is not registered!")
        }
    }
}
