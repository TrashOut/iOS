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
import Firebase
import FirebaseAuth
import FBSDKLoginKit

fileprivate func firAuthLog(_ message: String) {
    NSLog("FIR AUTH INFO: \(message)")
}

class FirebaseAuthentificator {

	init() {}

	var isAnonymous: Bool {
		get {
            return Auth.auth().currentUser?.isAnonymous ?? false
		}
	}

	func createAnonymousUser(_ completion: @escaping () -> ()) {
        Auth.auth().signInAnonymously(completion: { (user, error) in
			guard error == nil else {
				completion()
				return
			}
			guard user != nil else {
				completion()
				return
			}
            
            completion()
		})
	}

	func token(callback: @escaping (String?, Error?) -> ()) {
        if let user = Auth.auth().currentUser {
            user.getIDToken(completion: callback)
		} else {
			callback(nil, NSError.firUser)
		}
	}

	func uid() -> String? {
        return Auth.auth().currentUser?.uid
	}

	func resetPassword(email: String, callback: @escaping (Error?) -> ()) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: callback)
	}

    func createUser(email: String, password: String, callback: @escaping (String?, Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (firUser, error) in
            callback(firUser?.user.uid, error)
        })
    }
    
	func login(email: String, password: String, callback: @escaping (String?, Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (firUser, error) in
			callback(firUser?.user.uid, error)
		})
	}

    func loginWithFacebook(credentials: AuthCredential, callback: @escaping (String?, Error?) -> ()) {
        Auth.auth().signIn(with: credentials) { (firUser, error) in
            callback(firUser?.user.uid, error)
        }
    }

    func loginWithApple(credential: AuthCredential, callback: @escaping (AuthDataResult?, Error?) -> ()) {
        Auth.auth().signIn(with: credential) { authResult, error in
            callback(authResult, error)
        }
    }

    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            LoginManager().logOut()
        } catch let signOutError as NSError {
            firAuthLog(signOutError.description)
        }
    }

    func linkUser(email: String, password: String, callback: @escaping (String?, Error?) -> ()) {
        if let user = Auth.auth().currentUser {
            token { (token, error) in
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                user.link(with: credential) { (user, error) in
                    callback(user?.user.uid, error)
                }
            }
        }
    }

	func linkUser(facebookAccessToken: String, callback: @escaping (String?, Error?) -> ()) {
        if let user = Auth.auth().currentUser {
			self.token { (token, error) in
                let credential = FacebookAuthProvider.credential(withAccessToken: facebookAccessToken)
                user.link(with: credential) { (user, error) in
					callback(user?.user.uid, error)
				}
			}
		}
	}

    func linkUser(appleAuthResult: AuthDataResult, callback: @escaping (String?, Error?) -> ()) {
        if let user = Auth.auth().currentUser {
            self.token { (token, error) in
                if let credential = appleAuthResult.credential {
                    user.link(with: credential) { (user, error) in
                        callback(user?.user.uid, error)
                    }
                }
            }
        }
    }
    
    func sendVerificationEmail(callback: @escaping (Error?) -> ()) {
        if let user = Auth.auth().currentUser {
            self.token { (token, error) in
                user.sendEmailVerification() { (error) in
                    callback( error)
                }
            }
        }
    }
    
    func isUserLogedViaFacebook() -> Bool {
        if let userInfoArray = Auth.auth().currentUser?.providerData {
            for userInfo in userInfoArray {
                if userInfo.providerID == "facebook.com" {
                    return true
                }
            }
        }
        return false
    }
    
    func updateUserEmail(email: String, callback: @escaping (Error?) -> ()) {
        if let user = Auth.auth().currentUser {
            token { (token, error) in
                var steps: [Async.Block] = []
                /*steps.append({ (completion, failure) in
                    let credential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: password)
                    user.reauthenticate(with: credential, completion: { (error) in
                        guard error == nil else {
                            failure(error!)
                            return
                        }
                        completion()
                    })
                })
                */
                steps.append({ (completion, failure) in
                    user.updateEmail(to: email, completion: { (error) in
                        guard error == nil else {
                            failure(error!)
                            return
                        }
                        completion()
                    })
                })
                steps.append({ (completion, failure) in
                    user.sendEmailVerification() { (error) in
                        guard error == nil else {
                            failure(error!)
                            return
                        }
                        completion()
                    }
                })
                steps.append({ (completion, failure) in
                    callback(nil)
                })
                Async.waterfall(steps, failure: { (error) in
                    callback(error)
                })
            }
        }
    }
    
}
