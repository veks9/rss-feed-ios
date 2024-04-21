//
//  UIApplication+.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

extension UIApplication {
    static func topViewController(controller: UIViewController? = UIApplication.appWindow.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    static var appWindow: UIWindow {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIWindow()
    }
}
