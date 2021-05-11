//
//  UserManager+AppleLogin.swift
//  TrashOut
//
//  Created by Juraj Macák on 08/05/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices
import FirebaseAuth

// MARK: - Login with Apple

extension UserManager {

    func loginWithApple(_ controller: UIViewController) {
        guard Reachability.isConnectedToNetwork() else {
            delegate?.userManagerSignWithApple(error: NetworkingError.noInternetConnection)
            return
        }

        appleLoginManager.delegate = self

        if #available(iOS 13.0, *) {
            appleLoginManager.signIn()
        }
    }

}

// MARK: - AppleLoginManagerDelegate

extension UserManager: AppleLoginManagerDelegate {

    @available(iOS 13.0, *)
    func appleLoginDidReceivedError(_ error: ASAuthorizationError, callback: ErrorCaseCallback?) {
        delegate?.userManagerSignWithApple(error: error)
    }

    func appleLoginDidSignIn(credential: OAuthCredential) {
        firAuth.loginWithApple(credential: credential) { [weak self] authResult, error in
            guard let `self` = self else { return }

            if let error = error {
                self.delegate?.userManagerSignWithApple(error: error)
                return
            }

            self.loadDBMe() { (user, error) in
                guard let user = user else {
                    self.readUserDataFromFacebook() { (user, error) in
                        guard let user = user, error == nil else {
                            self.delegate?.userManagerSignWithApple(error: error)
                            return
                        }
                        self.createDBUser(user: user) { (user, error) in
                            guard let user = user, error == nil else {
                                self.delegate?.userManagerSignWithApple(error: error)
                                return
                            }
                            self.user = user
                            self.isLoggedIn = self.isAnonymous == false
                            self.delegate?.userManagerSignWithApple(error: error)
                        }
                    }
                    return
                }

                self.user = user
                self.isLoggedIn = self.isAnonymous == false
                self.delegate?.userManagerSignWithApple(error: nil)
            }
        }
    }

}
