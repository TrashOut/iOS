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
// import FBSDKLoginKit
import Firebase

class LoginViewController: ViewController, UITextFieldDelegate {

	@IBOutlet var scrollView: UIScrollView!

	@IBOutlet var frEmail: FormRow!
	@IBOutlet var frPassword: FormRow!

	@IBOutlet var btnLogin: UIButton!
	@IBOutlet var btnFacebook: UIButton!

	@IBOutlet var lblPassword: UILabel!
	@IBOutlet var btnPassword: UIButton!

	@IBOutlet var lblOr: UILabel!

	var selectedRow: FormRow?

	override func viewDidLoad() {
		super.viewDidLoad()

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

		let passwordText = NSAttributedString.init(string: "global.forgotPassword".localized, attributes: [
			NSForegroundColorAttributeName: UIColor.theme.green,
			NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
			])
		lblPassword.attributedText = passwordText

		frPassword.hideSeperator()
    }

	func validateForm() -> Bool {
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

	@IBAction func login() {
        
        // Hide error message for text fields
        frEmail.hideError()
        frPassword.hideError()
        
        // Validate form
		guard validateForm() else {return}
        
        // Login user
		let email = frEmail.textField.text!
		let password = frPassword.textField.text!
		UserManager.instance.login(email: email, password: password) { [weak self] (user, error) in
            

            
			guard error == nil else {
				print(error?.localizedDescription as Any)
                self?.show(error: error!)
				return
			}
			guard let user = user, user.id != 0 else {
				print("Failed to receive user")
				return
			}
			print("Successful logged as \(user.email ?? "no email")")
			self?.postLogin()
		}
	}

    @IBAction func loginWithFacebook(_ sender: UIButton) {
		UserManager.instance.loginWithFacebook(self) { [weak self] (error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
				self?.show(error: error!)
				return
			}
			guard let user = UserManager.instance.user else { return }
			print("Successful logged as \(user.email ?? "no email")")
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
                self?.show(error: error!)
				return
			}
			let m = String(format: "profile.resetPasswordInfoToMail".localized, email)
			self?.show(message: m)
		}
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

	func postLogin() {
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
