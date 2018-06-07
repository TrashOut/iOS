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

import Foundation
import Alamofire
import Firebase
import FBSDKLoginKit

fileprivate func apiLog(_ message: String) {
    NSLog("API INFO: \(message)")
}

fileprivate func firLog(_ message: String) {
    NSLog("FIR INFO: \(message)")
}

class UserManager {

	static let instance = UserManager()
	let firAuth = FirebaseAuthentificator.init()

	var user: User?

	var isAnonymous: Bool {
		get {
			return firAuth.isAnonymous
		}
	}

    // User cant be logged anonymously, then: isLoggedIn = false
    internal var isLoggedIn: Bool = false {
        didSet {
            if isLoggedIn == true {
                NotificationCenter.default.post(name: .userLoggedIn, object: nil)
            } else {
                NotificationCenter.default.post(name: .userLoggedOut, object: nil)
            }
        }
    }

    internal var token: String?

	/**
	Loads or creates anonymous user on firebase and DB if not exists
	*/
	func createAnonymousUser(callback: @escaping (User?, Error?) -> ()) {
        //firAuth.logout()
        let uid = firAuth.uid()
		if uid == nil || firAuth.isAnonymous {
			firAuth.createAnonymousUser { [unowned self] _ in
                self.loadDBMe() { (user, error) in
                    guard user != nil else {
                        self.createDBUser(user: User()) { [unowned self] (user, error) in
                            guard let user = user, error == nil else {
                                callback(nil, error)
                                return
                            }
                            self.user = user
                            self.isLoggedIn = self.isAnonymous == false
                            callback(user, error)
                        }
                        return
                    }
                    self.user = user
                    self.isLoggedIn = self.isAnonymous == false
                    callback(user, error)
                }
			}
		} else {
            self.loadDBMe() { [unowned self] (user, error) in
                guard user != nil else {
                    self.createDBUser(user: User()) { [unowned self] (user, error) in
                        guard let user = user, error == nil else {
                            callback(nil, error)
                            return
                        }
                        self.user = user
                        self.isLoggedIn = self.isAnonymous == false
                        callback(user, error)
                    }
                    return
                }
                self.user = user
                self.isLoggedIn = self.isAnonymous == false
                callback(user, error)
            }
		}
	}

    /**
    Get user token for headers
    */
	func tokenHeader(_ callback: @escaping (HTTPHeaders)->()) {
		firAuth.token { (token, error) in
			guard let token = token, error == nil else {
				callback([:])
				return
			}
			let headers: HTTPHeaders = ["X-Token": token]
			callback(headers)
		}
    }
    
    /**
     Load me via db (api)
     */
    func loadDBMe(callback: @escaping (User?, Error?) -> ()) {
        Networking.instance.userMe(callback: { (user, error) in
            if let e = error as NSError?, e.code == 404 {
                callback(nil, error)
            } else {
                guard let user = user, error == nil else {
                    callback(nil, error)
                    return
                }
                callback(user, error)
            }
        })
    }
    
    /**
     Load me via db (api)
     */
    func loadDBUser(userId: Int, callback: @escaping (User?, Error?) -> ()) {
        Networking.instance.user(userId, callback: { (user, error) in
            if let e = error as NSError?, e.code == 404 {
                callback(nil, error)
            } else {
                guard let user = user, error == nil else {
                    callback(nil, error)
                    return
                }
                callback(user, error)
            }
        })
    }

	/**
	Create user in db (api)
	*/
	func createDBUser (user: User, callback: @escaping (User?, Error?) -> ()) {
		guard let uid = firAuth.uid() else {
			callback(nil, NSError.firUid)
			return
		}
		Networking.instance.createUser(user: user, uid: uid) { (user, error) in
			guard let user = user, error == nil else {
				callback(nil, error)
				return
			}
			callback(user, error)
		}
	}
    
    /**
     Update user in db (api)
     */
    func updateDBUser(uid:String?, user: User?, callback: @escaping (Error?)->()) {
        guard let uid = uid else {
            return
        }
        guard let user = user else {
            return
        }
        let id = user.id
        Networking.instance.updateUser(user: user, id: id, uid: uid, image: nil) { [weak self] (id, error) in
            guard error == nil else {
                callback(error)
                return
            }
            self?.user = user
            callback(nil)
        }
    }

	/**
	Login using email and password
	*/
	func login(email: String, password: String, callback: @escaping (User?, Error?) -> ()) {
		firAuth.login(email: email, password: password) { [weak self] (uid, error) in
			guard error == nil else {
                if let error = error as NSError?, error.code == 17011 {
                    callback(nil, NSError.login)
                    return
                }
				callback(nil, error)
				return
			}
            Networking.instance.userMe { (user, error) in
                guard error == nil else {
                    callback(nil, error)
                    return
                }
                guard let user = user else {
                    callback(nil, nil)
                    return
                }
                self?.user = user
                callback(user, error)
                }

            self?.isLoggedIn = self?.isAnonymous == false
		}
	}

    /**
     Logout
     */
	func logout() {
        // clear neccessary data from facebook
        logoutFromFacebook()
        firAuth.logout()
        isLoggedIn = false
        createAnonymousUser { _,_ in }
	}
    
    // this method is called from tutorial. In this point we dont want to create anonymous user.
    func logoutOldUser() {
        // clear neccessary data from facebook
        logoutFromFacebook()
        firAuth.logout()
        isLoggedIn = false
    }

	/**
	Request password reset
	*/
	func resetPassword(email: String, callback: @escaping (Error?)->()) {
        firAuth.resetPassword(email: email, callback: callback)
	}

	/**
	Change user to registered using password and user data, update user on api
	*/
	func signup(user: User, password: String, callback: @escaping (Error?)->()) {

		guard let email = user.email else { return }
        if (self.isAnonymous && self.user != nil) {
            firAuth.linkUser(email: email, password: password) { [unowned self] (uid, error) in
                guard error == nil else {
                    if let error = error as NSError?, error.code == 17007 {
                        callback(NSError.signUp)
                        return
                    }
                    callback(error)
                    return
                }
                guard let _ = uid else {
                    callback(nil)
                    return
                }
                self.firAuth.sendVerificationEmail() { (error) in
                }
                self.firAuth.login(email: email, password: password, callback: { (uid, error) in
                    guard error == nil else {
                        callback(error)
                        return
                    }
                    guard self.firAuth.uid() != nil else {
                        callback(NSError.firUid)
                        return
                    }
                    Networking.instance.updateUser(user: user, id: (self.user?.id)!, uid: self.firAuth.uid()!, image: nil) { (id, error) in
                        guard error == nil else {
                            callback(error)
                            return
                        }
                       // user.id = self.user?.id ?? 0
                        self.user?.firstName = user.firstName
                        self.user?.lastName = user.lastName
                        self.user?.email = user.email
                        self.isLoggedIn = self.isAnonymous == false
                        callback(nil)
                    }
                })
            }
        } else {
            self.firAuth.createUser(email: email, password: password) { (uid, error) in
                guard error != nil else {
                    self.createDBUser(user: user) { [unowned self] (user, error) in
                        guard let user = user, error == nil else {
                            callback(error)
                            return
                        }
                        self.user = user
                        self.isLoggedIn = self.isAnonymous == false
                        callback(nil)
                    }
                    return
                }
                
                callback(error!)
            }
        }
	}

}
