//
//  FirebaseCrashlytics.swift
//  FirebaseCrashlytics
//
//  Created by Juraj Macák on 09/08/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import FirebaseCrashlytics

class FirebaseCrashlytics {

    /// Log custom error with Firebase Crashlyitics logger
    /// - Parameter customMessage: Custom String message
    static func track(customMessage: String) {
        Crashlytics.crashlytics().log(customMessage)
    }

}
