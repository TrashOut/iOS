//
//  AppleLoginManager.swift
//  TrashOut
//
//  Created by Juraj Macák on 09/05/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

typealias ErrorCaseCallback = (Error?) -> ()

/// Structure used for caching necesary attributres into keychain, can be modified in next steps.
struct AppleLoginCredentials {

    let email: String?
    let firstName: String?
    let lastName: String?

    @available(iOS 13.0, *)
    init(credentials: ASAuthorizationAppleIDCredential) {
        email = credentials.email
        firstName = credentials.fullName?.givenName
        lastName = credentials.fullName?.familyName
    }

}

// MARK: - Interface

protocol AppleLoginManagerDelegate: class {

    func appleLoginDidSignIn(credential: OAuthCredential)

    @available(iOS 13.0, *)
    func appleLoginDidReceivedError(_ error: ASAuthorizationError, callback: ErrorCaseCallback?)

}

class AppleLoginManager: NSObject {

    private let presentationContext: UIWindow?
    private var currentNonce: String?
    private var callback: ErrorCaseCallback?

    weak var delegate: AppleLoginManagerDelegate?

    init(presentationContext: UIWindow? = nil) {
        self.presentationContext = presentationContext
    }

}

// MARK: - Publics

extension AppleLoginManager {

    @available(iOS 13.0, *)
    func signIn(callback: ErrorCaseCallback? = nil) {
        self.callback = callback
        createLoginRequest()
    }

}

// MARK: - Privates

extension AppleLoginManager {

    @available(iOS 13.0, *)
    private func createLoginRequest() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }

}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager: ASAuthorizationControllerDelegate {

    @available(iOS 13.0, *)
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)

            delegate?.appleLoginDidSignIn(credential: credential)
        }
    }

    @available(iOS 13.0, *)
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let error = error as? ASAuthorizationError {
            delegate?.appleLoginDidReceivedError(error, callback: callback)
        }
    }

}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {

    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.presentationContext ?? UIApplication.shared.keyWindow ?? UIWindow()
    }

}
