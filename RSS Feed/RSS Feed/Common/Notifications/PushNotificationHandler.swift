//
//  PushNotificationHandler.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 24.04.2024..
//

import Foundation
import UserNotifications

final class PushNotificationHandler: NSObject {
    var appRootViewController: AppRootViewController?
        
    init(with appRootViewController: AppRootViewController?) {
        super.init()
        self.appRootViewController = appRootViewController
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationHandler: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        appRootViewController?.handleReceivedNotification(response: response)
        completionHandler()
    }
}
