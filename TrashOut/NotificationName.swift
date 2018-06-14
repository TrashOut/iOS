//
//  Notification.swift
//  TrashOut
//
//  Created by Lukáš Andrlik on 08/01/2018.
//  Copyright © 2018 TrashOut NGO. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let userCreatedTrash = Notification.Name("userCreatedTrash")
    static let userUpdatedTrash = Notification.Name("userUpdatedTrash")
    static let userJoindedEvent = Notification.Name("userJoindedEvent")
    static let userLoggedIn = Notification.Name("userLoggedIn")
    static let userLoggedOut = Notification.Name("userLoggedOut")
    static let receiveUserNotification = Notification.Name("kReceiveUserNotification")
}
