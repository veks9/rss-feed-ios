//
//  AppDelegate.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appRootViewController: AppRootViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        appRootViewController = AppRootViewController(viewModel: AppRootViewModel())
        window?.rootViewController = appRootViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}
