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
import UIKit
import Firebase
import AuthenticationServices

class LoginViewController: ViewController, UITextFieldDelegate {

    // MARK: - Outlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var loginButtonsStackView: UIStackView!
    @IBOutlet var frEmail: FormRow!
    @IBOutlet var frPassword: FormRow!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var btnFacebook: UIButton!
    @IBOutlet var lblPassword: UILabel!
    @IBOutlet var btnPassword: UIButton!
    @IBOutlet var lblOr: UILabel!

    // MARK: - Variables

    var selectedRow: FormRow?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupAppleLoginButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UserManager.instance.delegate = self
    }

}

// MARK: - IBActions

extension LoginViewController {

    @IBAction func login() {

        // Hide error message for text fields
        frEmail.hideError()
        frPassword.hideError()

        // Validate form
        guard validateForm() else { return }

        // Login user
        let email = frEmail.textField.text!
        let password = frPassword.textField.text!
        UserManager.instance.login(email: email, password: password) { [weak self] (user, error) in
            guard error == nil else {
                print(error?.localizedDescription as Any)

                if case NetworkingError.noInternetConnection = error! {
                    self?.show(error: NetworkingError.custom("global.internet.offline".localized))
                } else {
                    self?.show(error: error!)
                }
                return
            }
            guard let user = user, user.id != 0 else {
                print("Failed to receive user")
                return
            }
            print("Successful logged as \(user.email ?? "no email")")

            // Register notifications.
            NotificationsManager.unregisterUser { error in
                NotificationsManager.registerNotifications()
            }

            self?.postLogin()
        }
    }

    @IBAction func password () {
        let email = frEmail.textField.text ?? ""
        if email.count <= 0 {
            frEmail.showError("profile.validation.emailRequired".localized)
            return
        }
        UserManager.instance.resetPassword(email: email) { [weak self] (error) in
            guard error == nil else {
                if case NetworkingError.noInternetConnection = error! {
                    self?.show(error: NetworkingError.custom("global.internet.offline".localized))
                } else {
                    self?.show(error: error!)
                }
                return
            }
            let m = String(format: "profile.resetPasswordInfoToMail".localized, email)
            self?.showInfo(message: m)
        }
    }

    @IBAction func loginWithFacebook(_ sender: UIButton) {
        UserManager.instance.loginWithFacebook(self) { [weak self] (error) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                if case NetworkingError.noInternetConnection = error! {
                    self?.show(error: NetworkingError.custom("global.internet.offline".localized))
                } else {
                    self?.show(error: error!)
                }
                return
            }
            guard let user = UserManager.instance.user else { return }
            print("Successful logged as \(user.email ?? "no email")")
            self?.postLogin()

            // Register notifications.
            NotificationsManager.unregisterUser { error in
                NotificationsManager.registerNotifications()
            }
        }
    }

}

// MARK: - Privates

extension LoginViewController {

    private func setupAppleLoginButton() {
        if #available(iOS 13.0, *) {
            let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
            (authorizationButton as UIControl).cornerRadius = 20
            authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            authorizationButton.translatesAutoresizingMaskIntoConstraints = false
            authorizationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

            self.loginButtonsStackView.addArrangedSubview(authorizationButton)
        }
    }

    @objc private func handleAuthorizationAppleIDButtonPress() {
        UserManager.instance.loginWithApple(self)
    }

    private func setupView() {
        lblOr.text = "global.or".localized
        frEmail.textField.placeholder = "global.email".localized
        frPassword.textField.placeholder = "global.password".localized
        frPassword.textField.isSecureTextEntry = true
        frEmail.textField.keyboardType = .emailAddress

        btnFacebook.setTitle("global.facebookLogin".localized.uppercased(with: Locale.current), for: .normal)

        btnLogin.setTitle("global.login".localized.uppercased(), for: .normal)
        btnLogin.theme()
        btnFacebook.theme()
        btnFacebook.backgroundColor = UIColor.theme.facebook

        frEmail.hideError()
        frPassword.hideError()

        frEmail.textField.delegate = self
        frPassword.textField.delegate = self

        let passwordText = NSAttributedString.init(string: "global.forgotPassword".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.theme.green,
            convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle): NSUnderlineStyle.single.rawValue
        ]))
        lblPassword.attributedText = passwordText

        frPassword.hideSeperator()
    }

    private func validateForm() -> Bool {
        let email = frEmail.textField.text ?? ""
        let password = frPassword.textField.text ?? ""
        var hasError = false

        // Validate e-mail
        if email.count <= 0 {
            frEmail.showError("profile.validation.emailRequired".localized)
            hasError = true
        } else {
            do {
                let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: email, options: [], range: NSRange(location: 0, length: email.count))

                if matches.isEmpty {
                    hasError = true
                    frEmail.showError("profile.validation.invalidEmail".localized)
                }

            } catch {
                print(error.localizedDescription)
                hasError = true
            }
        }

        // Validate password
        if password.count <= 0 {
            frPassword.showError("profile.validation.passwordRequired".localized)
            hasError = true
        }

        return hasError == false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == frEmail.textField {
            self.selectedRow = frEmail
            UIView.animate(withDuration: 0.35, animations: {
                self.scrollView.contentOffset = CGPoint.init(x: 0, y: self.frEmail.frame.origin.y + 40)
            })
        }
        if textField == frPassword.textField {
            self.selectedRow = frPassword
            UIView.animate(withDuration: 0.35, animations: {
                self.scrollView.contentOffset = CGPoint.init(x: 0, y: self.frPassword.frame.origin.y + 40)
            })
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if let text = textField.text, text.count > 0 {
            self.selectedRow?.hideError()
        }

        selectedRow = nil

        return false
    }

    private func postLogin() {
        frEmail.textField.text = ""
        frEmail.textField.resignFirstResponder()
        frPassword.textField.text = ""
        frPassword.textField.resignFirstResponder()

        guard let tabbarController = self.navigationController?.parent as? TabbarViewController else {return}

        UIView.transition(with: tabbarController.view, duration: 0.35, options: [.transitionCrossDissolve], animations: {

            tabbarController.showLoggedTabbar()
            tabbarController.selectedIndex = 0
        }, completion: nil)
    }

}

extension LoginViewController: UserManagerDelegate {

    func userManagerSignWithApple(error: Error?) {
        guard error == nil else {
            print(error?.localizedDescription as Any)
            if case NetworkingError.noInternetConnection = error! {
                show(error: NetworkingError.custom("global.internet.offline".localized))
            } else {
                show(error: error!)
            }
            return
        }
        guard let user = UserManager.instance.user else { return }
        print("Successful logged as \(user.email ?? "no email")")
        postLogin()

        // Register notifications.
        NotificationsManager.unregisterUser { error in
            NotificationsManager.registerNotifications()
        }
    }

}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
