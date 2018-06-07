//
//  NotificationsManager.swift
//  TrashOut-Prod
//
//  Created by Grünvaldský Dávid on 05/06/2018.
//  Copyright © 2018 TrashOut NGO. All rights reserved.
//

import Foundation
import Firebase

enum Topic {
    case marketing(String)
    case news(String)
    
    var topicString: String {
        switch self {
        case .marketing(let locale): return "marketing-\(locale)"
        case .news(let locale): return "news-\(locale)"
        }
    }
}

class NotificationsManager {
    private static var currentLanguage: String {
        let availableLanguages: [String] = ["en_US", "cs_CZ", "de_DE", "es_ES", "sk_SK", "ru_RU"]
        var languages = Bundle.preferredLocalizations(from: availableLanguages).prefix(1)
        if languages.contains("en_US") == false {
            languages.append("en_US")
        }
        return languages[0]
    }
    
    
    static func registerDevice(tokenFCM: String? = nil, completion: @escaping (Error?) -> Void) {
        guard
            let token = tokenFCM ?? Messaging.messaging().fcmToken,
            let deviceId = UniqueIdentifier.identifier
        else { fatalError() }
        
        Networking.instance.registerDevice(tokenFCM: token, language: currentLanguage, deviceId: deviceId) { (user, error) in
            if error != nil {
                Messaging.messaging().subscribe(toTopic: Topic.marketing(currentLanguage).topicString)
                Messaging.messaging().subscribe(toTopic: Topic.news(currentLanguage).topicString)
            }
            
            completion(error)
        }
    }
    
    static func unregisterDevice(tokenFCM: String? = nil, completion: @escaping (Error?) -> Void) {
        guard let token = tokenFCM ?? Messaging.messaging().fcmToken else { fatalError() }
        
        Networking.instance.unregisterDevice(tokenFCM: token) { (_, error) in
            if error != nil {
                Messaging.messaging().unsubscribe(fromTopic: Topic.marketing(currentLanguage).topicString)
                Messaging.messaging().unsubscribe(fromTopic: Topic.news(currentLanguage).topicString)
            }
            
            completion(error)
        }
    }
}
