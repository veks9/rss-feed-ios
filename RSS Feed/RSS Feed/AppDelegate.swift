//
//  AppDelegate.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit
import BackgroundTasks

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appRootViewController: AppRootViewController?
    var pushNotificationHandler: PushNotificationHandler?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        appRootViewController = AppRootViewController(viewModel: AppRootViewModel())
        pushNotificationHandler = PushNotificationHandler(with: appRootViewController)
        window?.rootViewController = appRootViewController
        window?.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().delegate = pushNotificationHandler
        
        requestNotificationAuthorization()
        registerBackgroundTask()
        submitBackgroundTask()
        
        return true
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Granted")
            } else {
                print("Not granted")
            }
        }
    }
}

// MARK: - Background task configuration

extension AppDelegate {
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppConstants.backgroundTaskId, using: nil) { [weak self] task in
            guard let self, let task = task as? BGProcessingTask else { return }
            handleBackgroundTask(task: task)
        }
    }
    
    private func submitBackgroundTask() {
        BGTaskScheduler.shared.getPendingTaskRequests { request in
            print("\(request.count) BGTask pending.")
            guard request.isEmpty else { return }
            
            let request = BGProcessingTaskRequest(identifier: AppConstants.backgroundTaskId)
            request.requiresNetworkConnectivity = true
            request.requiresExternalPower = false
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // Schedule the next task in 1 minute
            
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Unable to schedule background task: \(error.localizedDescription)")
            }
        }
    }
    
    func handleBackgroundTask(task: BGProcessingTask) {
        scheduleNotification()
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "BBC World News"
        content.body = "New articles available"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["id": "https://feeds.bbci.co.uk/news/world/rss.xml"]
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
}
