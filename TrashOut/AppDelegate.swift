//
// TrashOut
// Copyright 2017 TrashOut NGO. All rights reserved.
// License GNU GPLv3
//

/**
  * TrashOut is an environmental project that teaches people how to recycle
  * and showcases the worst way of handling waste - illegal dumping. All you need is a smart phone.
  *
  *
  * There are 10 types of programmers - those who are helping TrashOut and those who are not.
  * Clean up our code, so we can clean up our planet.
  * Get in touch with us: help@trashout.ngo
  *
  * Copyright 2017 TrashOut, n.f.
  *
  * This file is part of the TrashOut project.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * See the GNU General Public License for more details: <https://www.gnu.org/licenses/>.
 */

import UIKit
import Firebase
//import FBSDKLoginKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?

	// MARK: - App Delegate

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let file = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        let opt = FirebaseOptions.init(contentsOfFile: file!)
        FirebaseApp.configure(options: opt!)
		Theme.current.setupAppearance()
		FirebaseLocalization().update()
		acceptInvalidSSLCerts()
		return true
	}

    func applicationWillResignActive(_ application: UIApplication) {
		TrashHunter.hunter?.appWillResignActive(application)
    }

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
	}

	func application(_ application: UIApplication, didReceive notification: UILocalNotification) {

		TrashHunter.hunter?.application(application, didReceive: notification)
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
		TrashHunter.hunter?.application(application, didRegister: notificationSettings)
	}

    /*
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		// print out token to device console
		NSLog("Registered for notifications with token: '\(deviceToken)'")
	}
    */

    /*
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		// print out error to device console
		NSLog("Failed to register for notifications due to error \(error.localizedDescription)")
	}
    */
 
	func acceptInvalidSSLCerts() {
		let manager = Alamofire.SessionManager.default
		print("trying to accept invalid certs")
		
		manager.delegate.sessionDidReceiveChallenge = { session, challenge in
			var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
			var credential: URLCredential?
			
			print("received challenge")
			
			if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
				disposition = URLSession.AuthChallengeDisposition.useCredential
				credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
			} else {
				if challenge.previousFailureCount > 0 {
					disposition = .cancelAuthenticationChallenge
				} else {
					credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
					
					if credential != nil {
						disposition = .useCredential
					}
				}
			}
			
			return (disposition, credential)
		}
	}
}
