//
//  AppDelegate.swift
//  RSS Feed
//
//  Created by Vedran Hernaus on 18.04.2024..
//

import UIKit
import BackgroundTasks
import Combine
import FeedKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appRootViewController: AppRootViewController?
    var pushNotificationHandler: PushNotificationHandler?
    let feedService: FeedServicing = FeedService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        appRootViewController = AppRootViewController(viewModel: AppRootViewModel())
        pushNotificationHandler = PushNotificationHandler(with: appRootViewController)
        window?.rootViewController = appRootViewController
        window?.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().delegate = pushNotificationHandler
        
        requestNotificationAuthorization()
        
        return true
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (granted, error) in
            if granted {
                print("Granted")
                self?.registerBackgroundTask()
                self?.submitBackgroundTask()
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
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            guard requests.isEmpty else { return }
            let request = BGProcessingTaskRequest(identifier: AppConstants.backgroundTaskId)
            request.requiresNetworkConnectivity = true
            request.requiresExternalPower = false
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 15)
            
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Unable to schedule background task: \(error.localizedDescription)")
            }
        }
    }
    
    func handleBackgroundTask(task: BGProcessingTask) {
        feedService.getAllFeeds()
            .map {
                $0.filter { $0.isNotificationsEnabled }
            }
            .flatMap({ [feedService] feedModels in
                Publishers.CombineLatestArray(
                    feedModels.compactMap { feedModel -> AnyPublisher<(String, RSSFeed), Error> in
                        guard let rssUrl = feedModel.rssUrl, let url = URL(string: rssUrl) else {
                            return Empty<(String, RSSFeed), Error>(completeImmediately: false).eraseToAnyPublisher()
                        }
                        return feedService.fetchFeed(for: url)
                            .map { (rssUrl, $0) }
                            .eraseToAnyPublisher()
                    }
                )
                .map { fetchedFeedModels in
                    (feedModels, fetchedFeedModels)
                }
            })
            .ignoreFailure()
            .sink(receiveValue: { [weak self] feeds, fetchedFeeds in
                guard let self else { return }
                checkForNewChanges(feeds: feeds, fetchedFeeds: fetchedFeeds)
            })
            .store(in: &cancellables)
        task.setTaskCompleted(success: true)
        submitBackgroundTask()
    }
    
    private func checkForNewChanges(feeds: [FeedModel], fetchedFeeds: [(String, RSSFeed)]) {
        feeds.forEach { feed in
            guard let fetchedFeed = fetchedFeeds.filter({ $0.0 == feed.rssUrl }).first else { return }
            let newFeedItems = fetchedFeed.1.items?.filter({ fetchedFeedItem in
                !feed.itemsArray.contains { $0.title == fetchedFeedItem.title }
            }) ?? []
            guard !newFeedItems.isEmpty else { return }
            feedService.createOrUpdateFeed(from: fetchedFeed.1, rssUrl: fetchedFeed.0)
                .ignoreFailure()
                .sink { [weak self] updatedFeed in
                    self?.scheduleNotification(from: updatedFeed)
                }
                .store(in: &cancellables)
            
        }
    }
    
    private func scheduleNotification(from feed: FeedModel) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = feed.title ?? ""
        content.body = "notification_new_articles_body".localized()
        content.categoryIdentifier = "alarm"
        content.userInfo = ["id": feed.id ?? ""]
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
}
