//
//  NotificationsManager.swift
//  TrashOut-Prod
//
//  Created by Grünvaldský Dávid on 05/06/2018.
//  Copyright © 2018 TrashOut NGO. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications

/// Topic for subscribing.
///
/// - marketing: Marketing.
/// - news: News.
enum Topic {
    case marketing(String)
    case news(String)
    
    /// Topic string.
    var topicString: String {
        switch self {
        case .marketing(let locale): return "marketing-\(locale)"
        case .news(let locale): return "news-\(locale)"
        }
    }
}

/// Notification report type.
///
/// - event: Event.
/// - trash: Trash.
/// - news: News.
enum NotificationReportType: String {
    case event = "event"
    case trash = "trash"
    case news  = "news"
}

/// Notification target type.
///
/// - report: Report.
/// - marketing: Marketing.
enum NotificationTargetType {
    case report
    case marketing
}


/// App open mode.
///
/// - normal: Normal.
/// - pushNotification: Push notification.
enum AppOpenMode {
    case normal
    case pushNotification([AnyHashable : Any])
}

/// Notification manager.
class NotificationsManager {
    
    /// App open.
    public class AppOpen {
        
        /// Shared instance.
        public static let shared = AppOpen()
        
        /// Mode.
        var mode: AppOpenMode? = nil
    }
    
    
    /// Current language.
    private static var currentLanguage: String {
        let availableLanguages: [String] = ["en_US", "cs_CZ", "de_DE", "es_ES", "sk_SK", "ru_RU"]
        var languages = Bundle.preferredLocalizations(from: availableLanguages).prefix(1)
        if languages.contains("en_US") == false {
            languages.append("en_US")
        }
        return languages[0]
    }
    
    /// Register app for notifications
    static func registerNotifications() {
        
        // Register notifications - device
        let application: UIApplication = UIApplication.shared
        guard let delegate = (application.delegate as? AppDelegate) else { return }
        delegate.registerNotifications(application: application)
        
        // Register notification - server
        NotificationsManager.registerUser { error in
            if error != nil { print(error!.localizedDescription) }
        }
    }
    
    
    /// Register user for notifications.
    ///
    /// - Parameters:
    ///   - tokenFCM: FCM token.
    ///   - completion: Completion handler.
    static func registerUser(tokenFCM: String? = nil, completion: @escaping (Error?) -> Void) {
        guard
            let token = tokenFCM ?? Messaging.messaging().fcmToken,
            let deviceId = UniqueIdentifier.identifier
        else { return }
        
        Networking.instance.registerUser(tokenFCM: token, language: currentLanguage, deviceId: deviceId) { (user, error) in
            let breakpoint = { print("") }
            breakpoint()
            
            if error == nil && user != nil {
                Messaging.messaging().subscribe(toTopic: Topic.marketing(currentLanguage).topicString)
                Messaging.messaging().subscribe(toTopic: Topic.news(currentLanguage).topicString)
            }
            
            completion(error)
        }
    }
    
    /// Unregister user for notifications.
    ///
    /// - Parameters:
    ///   - tokenFCM: FCM token.
    ///   - completion: Completion handler.
    static func unregisterUser(tokenFCM: String? = nil, completion: @escaping (Error?) -> Void) {
        guard let token = tokenFCM ?? Messaging.messaging().fcmToken else { return }
        
        Networking.instance.unregisterUser(tokenFCM: token) { (_, error) in
            if error != nil {
                Messaging.messaging().unsubscribe(fromTopic: Topic.marketing(currentLanguage).topicString)
                Messaging.messaging().unsubscribe(fromTopic: Topic.news(currentLanguage).topicString)
            }
            
            completion(error)
        }
    }
}

// MARK: - Handle data
extension NotificationsManager {
    /// Handle received notification data.
    ///
    /// - Parameters:
    ///   - data: Data.
    ///   - completion: Completion handler.
    static func handleNotificationData(_ notificationData: [AnyHashable : Any], completion: @escaping (NotificationData) -> Void) {
        
        // Keys for notification data
        let kAps: String     = "aps"
        let kData: String    = "data"
        let kAlert: String   = "alert"
        let kType: String    = "type"
        let kTitle: String   = "title-loc-key"
        let kBody: String    = "loc-key"
        let kTrashId: String = "trash_id"
        let kEventId: String = "event_id"
        let kNewsId: String  = "news_id"
        
        
        // Report notifications
        if
            let data = notificationData[kData] as? [AnyHashable : Any],
            let aps = notificationData[kAps] as? [AnyHashable : Any],
            let alert = aps[kAlert] as? [AnyHashable : Any],
            let typeData = data[kType] as? String
        {
            if let type = NotificationReportType(rawValue: typeData) {
                let notificationData = NotificationData(type: .report, reportType: type, id: nil, title: alert[kTitle] as? String, message: alert[kBody] as? String)
                
                if case .event = type { notificationData.id = Int(data[kEventId] as! String) }
                if case .trash = type { notificationData.id = Int(data[kTrashId] as! String) }
                if case .news = type { notificationData.id = Int(data[kNewsId] as! String) }
                
                completion(notificationData)
                return
            }
        }
        
        // Marketing notifications
        if
            let aps = notificationData[kAps] as? [AnyHashable : Any],
            let alert = aps[kAlert] as? [AnyHashable : Any]
        {
            let notificationData = NotificationData(type: .marketing, reportType: nil, id: nil, title: alert[kTitle] as? String, message: alert[kBody] as? String)
            
            completion(notificationData)
            return
        }
    }
}

// MARK: - Coordinating
extension NotificationsManager {
    
    /// Show notification alert controller.
    ///
    /// - Parameters:
    ///   - viewController: Presenting view controller.
    ///   - data: Data for showing.
    static func showNotificationAlertController(overVC viewController: UIViewController, notificationData data: NotificationData) {
        let ac = UIAlertController(title: data.title?.localized, message: data.message?.localized, preferredStyle: .alert)
        
        switch data.type {
        case .report:
            ac.addAction(UIAlertAction(title: "global.showDetail".localized, style: .default, handler: { _ in
                data.actionHandler?()
            }))
            
            ac.addAction(UIAlertAction(title: "global.cancel".localized, style: .cancel, handler: nil))
            
            break
            
        case .marketing:
            ac.addAction(UIAlertAction(title: "global.ok".localized, style: .default, handler: nil))
            break
        }
        
        viewController.present(ac, animated: true, completion: nil)
    }
    
    
    /// Show dump after receive notification/
    ///
    /// - Parameters:
    ///   - tabBarController: Tab bar controller.
    ///   - id: ID.
    static func showDumpsAfterReceiveNotification(tabBarController: TabbarViewController?, id: Int?) {
        if let visibleController = ((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? UINavigationController)?.visibleViewController {
            visibleController.dismiss(animated: true, completion: nil)
        }
        
        
        tabBarController?.openDashboard { nc in
            let storyboard = UIStoryboard.init(name: "Dumps", bundle: Bundle.main)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "DumpsDetailViewController") as? DumpsDetailViewController else { fatalError("Could not dequeue storyboard with identifier: DumpsDetailViewController") }
            vc.id = id
            nc.pushViewController(vc, animated: true)
        }
    }
    
    /// Show event after receive notification/
    ///
    /// - Parameters:
    ///   - tabBarController: Tab bar controller.
    ///   - id: ID.
    static func showEventAfterReceiveNotification(tabBarController: TabbarViewController?, id: Int?) {
        if let visibleController = ((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? UINavigationController)?.visibleViewController {
            visibleController.dismiss(animated: true, completion: nil)
        }
        
        tabBarController?.openDashboard { nc in
            let storyboard = UIStoryboard(name: "Event", bundle: Bundle.main)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController else { fatalError("Could not dequeue storyboard with identifier: EventDetailViewController") }
            vc.showJoinButton = false
            vc.id = id
            nc.pushViewController(vc, animated: true)
        }
    }
    
    /// Show news after receive notification/
    ///
    /// - Parameters:
    ///   - tabBarController: Tab bar controller.
    ///   - id: ID.
    static func showNewsAfterReceiveNotification(tabBarController: TabbarViewController?, id: Int?) {
        if let visibleController = ((UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? UINavigationController)?.visibleViewController {
            visibleController.dismiss(animated: true, completion: nil)
        }
        
        tabBarController?.openDashboard { nc in
            let storyboard = UIStoryboard.init(name: "News", bundle: Bundle.main)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "NewsDetailViewController") as? NewsDetailViewController else { fatalError("Could not dequeue storyboard with identifier: NewsDetailViewController") }
            vc.articleId = id
            nc.pushViewController(vc, animated: true)
        }
    }
}
