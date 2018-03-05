//
//  UserManager+Facebook.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 25.01.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import Firebase

fileprivate func fbLog(_ message: String) {
	NSLog("FB INFO: \(message)")
}

extension UserManager {

    enum FBLoginAction {
        case direct
        case anonymous
    }
    
	/**
	Login with facebook

	1. login using facebook sdk
	2.
	3.
	4.

	*/
	func loginWithFacebook(_ controller: UIViewController, callback: @escaping (Error?) -> ()) {
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(withReadPermissions: ["email", "public_profile"], from: controller) { (result, error) in
            if let error = error {
                callback(error)
                return
            }
            guard let fbloginresult = result else {
                callback(NSError.fbLoginResult)
                return
            }
            if let fbloginreslut = result {
                if fbloginreslut.isCancelled == true {
                    callback(nil)
                }
            }
            guard let grantedPermissions = fbloginresult.grantedPermissions,
                grantedPermissions.contains("email") else {
                callback(NSError.fbGrantedPermissions)
                return
            }
            guard let accessToken = FBSDKAccessToken.current().tokenString else {
                callback(NSError.fbAccessToken)
                return
            }

            if (self.isAnonymous && self.user != nil) {
                self.linkUserWithFacebook(facebookAccessToken: accessToken, callback: callback)
            } else {
                self.loginIntoFirebaseWithFacebook(action:.direct, facebookAccessToken: accessToken, callback: callback)
            }
        }
    }
    
	/**
	*/
    internal func loginIntoFirebaseWithFacebook(action:FBLoginAction, facebookAccessToken: String, callback: @escaping (Error?) -> ()) {
		let credentials = FIRFacebookAuthProvider.credential(withAccessToken: facebookAccessToken)
		firAuth.loginWithFacebook(credentials: credentials) { [unowned self] (uid, error) in
			if error != nil {
                callback(error)
			} else {
                 if action == .direct {
                    self.loadDBMe() { (user, error) in
                        guard let user = user else {
                            // If user not exists
                            self.readUserDataFromFacebook() { (user, error) in
                                guard let user = user, error == nil else {
                                    callback(error)
                                    return
                                }
                                self.createDBUser(user: user) { (user, error) in
                                    guard let user = user, error == nil else {
                                        callback(error)
                                        return
                                    }
                                    self.user = user
                                    self.isLoggedIn = self.isAnonymous == false
                                    callback(nil)
                                }
                            }
                            return
                        }
                        
                        self.user = user
                        self.isLoggedIn = self.isAnonymous == false
                        callback(nil)
                    }
                } else if action == .anonymous  {
                    self.loadDBMe() { (user, error) in
                    guard let user = user, error == nil else {
                        callback(error)
                        return
                    }
                    self.user = user
                    self.isLoggedIn = self.isAnonymous == false
                    callback(nil)
                }
            }

                
                /*
                self.loadDBUser() { (user, error) in
                    guard let user = user else {
                        // If user not exists
                        self.readUserDataFromFacebook() { (user, error) in
                            guard let user = user, error == nil else {
                                callback(error)
                                return
                            }
                            self.createDBUser(user: user) { (user, error) in
                                guard let user = user, error == nil else {
                                    callback(error)
                                    return
                                }
                                self.user = user
                                self.isLoggedIn = self.isAnonymous == false
                                callback(nil)
                            }
                        }
                        return
                    }
                    
                    self.user = user
                    self.isLoggedIn = self.isAnonymous == false
                    callback(nil)
                }
                */
			}
		}
	}

	/**
	*/
	internal func linkUserWithFacebook(facebookAccessToken: String, callback: @escaping (Error?) -> ()) {
        //let credentials = FIRFacebookAuthProvider.credential(withAccessToken: facebookAccessToken)
        //firAuth.loginWithFacebook(credentials: credentials) { [unowned self] (uid, error) in
        //}
        firAuth.linkUser(facebookAccessToken: facebookAccessToken) { (uid, error) in
			guard error == nil else {
                if let error = error as NSError?, error.code == 17999 {
                    callback(NSError.fbLinkUser)
                } else if let error = error as NSError?, error.code == 17025 {
                    // User is already linked, then try login (load)
                    self.loginIntoFirebaseWithFacebook(action:.anonymous, facebookAccessToken: facebookAccessToken, callback: callback)
                    //callback(error)
                } else {
                    callback(error)
                }
				return
			}
			guard let uid = uid else {
				callback(NSError.firUid)
				return
			}
            // If user not exists
            self.readUserDataFromFacebook() { (user, error) in
                guard let user = user, error == nil else {
                    callback(error)
                    return
                }
                self.user?.firstName = user.firstName
                self.user?.lastName = user.lastName
                self.user?.email = user.email
                self.user?.uid = uid
                self.isLoggedIn = self.isAnonymous == false
                self.updateDBUser(uid: uid, user: self.user, callback: callback)
            }
		}
	}

	/**
	Read user data from Facebook
	*/
	internal func readUserDataFromFacebook(callback: @escaping (User?, Error?) -> ()) {
		FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "first_name, last_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
			guard error == nil else {
				callback(nil, error)
				return
			}
			guard let result = result as? [String: Any] else {
				callback(nil, NSError.fbProfileData)
				return
			}
            let user = User()
            user.firstName = result["first_name"] as? String
            user.lastName = result["last_name"] as? String
            user.email = result["email"] as? String
            callback(user, nil)
		})
	}
}
