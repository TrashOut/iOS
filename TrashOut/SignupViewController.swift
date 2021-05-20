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

class SignupViewController: ViewController, UITextFieldDelegate {

	@IBOutlet var scrollView: UIScrollView!

	@IBOutlet var frName: FormRow!
	@IBOutlet var frSurname: FormRow!
	@IBOutlet var frEmail: FormRow!
	@IBOutlet var frPassword: FormRow!
	@IBOutlet var frPasswordCheck: FormRow!

	@IBOutlet var btnLogin: UIButton!
	@IBOutlet var btnFacebook: UIButton!

    @IBOutlet weak var policyLinkButton: UIButton!
    @IBOutlet weak var termsLinkButton: UIButton!


	@IBOutlet var lblOr: UILabel!
    @IBOutlet weak var tvTermsAndConditions: UITextView?

    @IBOutlet weak var signUpButtonStackView: UIStackView!
    
	var selectedRow: FormRow?
    var dict : [String : AnyObject]!

	override func viewDidLoad() {
		super.viewDidLoad()

        setupAppleLoginButton()
        setupView()
	}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UserManager.instance.delegate = self
    }

	/**
	Validate form for errors
	
	- Returns: true if form is valid
	*/
	func validateForm() -> Bool {
        
        frName.hideError()
        frSurname.hideError()
        frEmail.hideError()
        frPassword.hideError()
        frPasswordCheck.hideError()
        
		let name = frName.textField.text ?? ""
		let surname = frSurname.textField.text ?? ""
		let email = frEmail.textField.text ?? ""
		let password = frPassword.textField.text ?? ""

		var hasErrors: Bool = false
		if name.count <= 0 {
			frName.showError("user.validation.firstNameRequired".localized)
			hasErrors = true
		}
		if surname.count <= 0 {
			frSurname.showError("user.validation.lastNameRequired".localized)
			hasErrors = true
		}
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		if NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email) == false {
			frEmail.showError("profile.validation.invalidEmail".localized)
			hasErrors = true
		}
		if password.count <= 0 {
			frPassword.showError("profile.validation.passwordRequired".localized)
			hasErrors = true
		}
        if password.count < 8 {
            frPassword.showError("user.validation.passwordTooShort".localized)
            return false
        }
        if password.count > 50 {
            frPassword.showError("global.validation.passwordTooLong".localized)
            return false
        }
		if frPassword.textField.text != frPasswordCheck.textField.text {
			frPasswordCheck.showError("user.validation.passwordsNotMatch".localized)
			hasErrors = true
		}
        
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d!@#$%^&*()-_=+{}|?>.<,:;~`’]{8,50}$"
        if NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password) == false {
            frPassword.showError("user.validation.passwordShouldContain".localized)
            return false
        }
        
		return hasErrors == false
	}

    @IBAction func signup() {
		guard self.validateForm() else { return }
		let name = frName.textField.text
		let surname = frSurname.textField.text
		let email = frEmail.textField.text
		let password = frPassword.textField.text

		let user = User()
		user.firstName = name
		user.lastName = surname
		user.email = email

		UserManager.instance.signup(user: user, password: password!) { [weak self] (error) in

			if let error = error {
                print(error.localizedDescription)
                
                if case NetworkingError.noInternetConnection = error {
                    self?.show(error: NetworkingError.custom("global.internet.offline".localized))
                } else {
                    self?.show(error: error)
                }
                
				return
			}
			self?.postSignUp()
            
            // Register notifications.
            NotificationsManager.unregisterUser { error in
                NotificationsManager.registerNotifications()
            }
		}
	}

	@IBAction func facebook() {
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
			self?.postSignUp()
            
            // Register notifications.
            NotificationsManager.unregisterUser { error in
                NotificationsManager.registerNotifications()
            }
		}
    }

    @IBAction func termsButtonPressed(_ sender: Any) {
        UIApplication.shared.open(Link.termsAndConditions.url)
    }
    
    @IBAction func policyButtonPressed(_ sender: Any) {
        UIApplication.shared.open(Link.privacyPolicy.url)
    }
    
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == frName.textField {
			self.selectedRow = frName
		}
		if textField == frSurname.textField {
			self.selectedRow = frSurname
		}
		if textField == frEmail.textField {
			self.selectedRow = frEmail
		}
		if textField == frPassword.textField {
			self.selectedRow = frPassword
		}
		if textField == frPasswordCheck.textField {
			self.selectedRow = frPasswordCheck
		}
		if let row = self.selectedRow {
			UIView.animate(withDuration: 0.35, animations: {
				self.scrollView.contentOffset = CGPoint.init(x: 0, y: row.frame.origin.y + 40)
			})
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()

		if let text = textField.text, text.count > 0 {
			self.selectedRow?.hideError()
		}

		self.selectedRow = nil

		return false
	}

	func postSignUp() {
		guard let tabbarController = self.navigationController?.parent as? TabbarViewController else {return}

        frName.textField.text = ""
        frName.textField.resignFirstResponder()
        frSurname.textField.text = ""
        frSurname.textField.resignFirstResponder()
        frEmail.textField.text = ""
        frEmail.textField.resignFirstResponder()
        frPassword.textField.text = ""
        frPassword.textField.resignFirstResponder()
        frPasswordCheck.textField.text = ""
        frPasswordCheck.textField.resignFirstResponder()
        
		UIView.transition(with: tabbarController.view, duration: 0.35, options: [.transitionCrossDissolve], animations: {

			tabbarController.showLoggedTabbar()
			tabbarController.selectedIndex = 0
			}, completion: nil)
	}

}


// MARK: - Privates

extension SignupViewController {

    private func setupView() {
        lblOr.text = "global.or".localized
        frName.textField.placeholder = "user.firstName".localized
        frSurname.textField.placeholder = "user.lastName".localized
        frEmail.textField.placeholder = "global.email".localized
        frPassword.textField.placeholder = "global.password".localized
        frPasswordCheck.textField.placeholder = "user.reEnterPassword".localized
        btnFacebook.setTitle("global.facebookLogin".localized.uppercased(with: Locale.current), for: .normal)
        frPasswordCheck.hideSeperator()
        frName.textField.delegate = self
        frSurname.textField.delegate = self
        frEmail.textField.delegate = self
        frPassword.textField.delegate = self
        frPasswordCheck.textField.delegate = self
        frPassword.textField.isSecureTextEntry = true
        frPasswordCheck.textField.isSecureTextEntry = true
        frEmail.textField.keyboardType = .emailAddress
        btnLogin.setTitle("global.register".localized.uppercased(), for: .normal)
        btnLogin.theme()
        btnFacebook.theme()
        btnFacebook.backgroundColor = UIColor.theme.facebook
        tvTermsAndConditions?.text = "global.register.terms".localized
        termsLinkButton.setTitle("global.signUp.acceptRegister.terms".localized, for: .normal)
        policyLinkButton.setTitle("global.signUp.acceptRegister.privatePolicy".localized, for: .normal)

        termsLinkButton.tintColor = UIColor.theme.green
        policyLinkButton.tintColor = UIColor.theme.green
        termsLinkButton.setTitleColor(UIColor.theme.green, for: .normal)
        policyLinkButton.setTitleColor(UIColor.theme.green, for: .normal)
    }
    
    /// Create attributed string for terms and conditions.

    private func setupAppleLoginButton() {
        if #available(iOS 13.0, *) {
            let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
            (authorizationButton as UIControl).cornerRadius = 20
            authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            authorizationButton.translatesAutoresizingMaskIntoConstraints = false
            authorizationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

            self.signUpButtonStackView.addArrangedSubview(authorizationButton)
        }
    }

    @objc private func handleAuthorizationAppleIDButtonPress() {
        UserManager.instance.loginWithApple(self)
    }

}

extension SignupViewController: UserManagerDelegate {

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
        postSignUp()

        // Register notifications.
        NotificationsManager.unregisterUser { error in
            NotificationsManager.registerNotifications()
        }
    }

}
