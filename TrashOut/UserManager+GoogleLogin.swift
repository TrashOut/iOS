//
//  UserManager+GoogleLogin.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 16/08/2023.
//  Copyright © 2023 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn

extension UserManager {

    func loginWithGoogle(_ controller: UIViewController, callback: @escaping (Error?) -> ()) {
        guard Reachability.isConnectedToNetwork() else {
            return callback(NetworkingError.noInternetConnection)
        }

        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: controller) { [unowned self] result, error in
            guard error == nil else {
                callback(error)
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return callback(NetworkingError.apiError)
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            firAuth.loginWithGoogle(credentials: credential) { [weak self] result, error in
                self?.loadDBMe() { (user, error) in
                    guard let user else {
                        let user = User()
                        user.firstName = result?.user.displayName
                        user.email = result?.user.email

                        self?.createDBUser(user: user, callback: { newUser, error in
                            self?.user = newUser
                            self?.isLoggedIn = self?.isAnonymous == false
                            callback(error)
                        })
                        return
                    }
                    self?.user = user
                    self?.isLoggedIn = self?.isAnonymous == false
                    callback(error)
                }
            }
        }
    }
}
