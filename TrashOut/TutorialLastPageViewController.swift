//
//  TutorialLastPageViewController.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 29.03.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices

class TutorialLastPageViewController: ViewController {

	@IBOutlet var ivImage: UIImageView!
	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var lblText: UILabel!

	@IBOutlet var btnSignin: UIButton!
	@IBOutlet var btnFacebook: UIButton!
	@IBOutlet var lblProcess: UILabel!
    @IBOutlet weak var buttonStackView: UIStackView!

    @IBOutlet weak var policyLinkButton: UIButton!
    @IBOutlet weak var termsLinkButton: UIButton!
    @IBOutlet weak var tvTermsAndConditions: UITextView?


	var page: TutorialPage?
	var index: Int = 0


	override func viewDidLoad() {
		super.viewDidLoad()

        setupAppleLoginButton()
        setupView()
	}

	@IBAction func signIn() {
		self.askPermissions { [weak self] in
			guard let main = self?.loadSignIn() else { return }
			self?.changeRoot(viewController: main)
		}
	}

	@IBAction func process() {
		self.askPermissions { 
            UserManager.instance.createAnonymousUser { [weak self] (user, error) in
                guard let main = self?.main() else { return }
                self?.changeRoot(viewController: main)
                
                // Register notifications.
                NotificationsManager.registerNotifications()
            }
		}
	}

	@IBAction func facebookSignIn() {
		UserManager.instance.loginWithFacebook(self) { [weak self] (error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
				self?.show(error: error!)
				return
			}
			guard let user = UserManager.instance.user else { return }
			print("Successful logged as \(user.email ?? "no email")")

			self?.askPermissions { [weak self] in
				guard let main = self?.main() else { return }
				self?.changeRoot(viewController: main)
			}
            
            // Register notifications.
            NotificationsManager.registerNotifications()
		}
	}


	var trashHunter: TrashHunter? {
		didSet {
			TrashHunter.hunter = trashHunter
		}
	}
	func askPermissions(completion: @escaping ()->()) {
		Async.waterfall([
		                  { [weak self] (completion: @escaping ()->(), _) in

				let config = TrashHunterConfig()
				self?.trashHunter = TrashHunter.init(config)
				self?.trashHunter?.prepareNotifications(success: {
					self?.trashHunter = nil
					completion()
				}, failure: completion)
			}, { (completion: @escaping ()->(), _) in
				LocationManager.manager.refreshCurrentLocation({ (_) in // TODO: wait for it
					completion()
				})
			}, { (c, _) in
				completion()
				c()
			}
			], failure: { (_) in
			completion()
		})
	}


	func loadSignIn() -> UIViewController? {
		guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as? TabbarViewController else { return nil }
		vc.signIn = true
		return vc
	}

	func main() -> UIViewController? {
		guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() else { return nil }
		return vc
	}

	func changeRoot(viewController: UIViewController) {
		guard let window = UIApplication.shared.keyWindow else { return }
		guard let snapshot = window.snapshotView(afterScreenUpdates: true) else { return }
		viewController.view.addSubview(snapshot)
		window.rootViewController = viewController
		UIView.animate(withDuration: 0.35, animations: {
			snapshot.layer.opacity = 0
			snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
		}) { (_) in
			snapshot.removeFromSuperview()
		}
	}

    @IBAction func termsButtonPressed(_ sender: Any) {
        UIApplication.shared.open(Link.termsAndConditions.url)
    }

    @IBAction func policyButtonPressed(_ sender: Any) {
        UIApplication.shared.open(Link.privacyPolicy.url)
    }

}

// MARK: - Private

extension TutorialLastPageViewController {

    private func setupAppleLoginButton() {
        if #available(iOS 13.0, *) {
            let authorizationButton = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
            (authorizationButton as UIControl).cornerRadius = 20
            authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            authorizationButton.translatesAutoresizingMaskIntoConstraints = false
            authorizationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

            self.buttonStackView.insertArrangedSubview(authorizationButton, at: buttonStackView.arrangedSubviews.count - 2)
        }
    }

    @objc private func handleAuthorizationAppleIDButtonPress() {
        UserManager.instance.loginWithApple(self)
    }

    private func setupView() {
        ivImage.image = page?.image
        lblTitle.text = page?.title
        lblText.text = page?.content

        btnSignin.setTitle("tutorial.register".localized, for: .normal)
        btnFacebook.setTitle("global.facebookLogin".localized, for: .normal)
        lblProcess.attributedText = NSAttributedString.init(string: "tutorial.signup.withoutSignIn".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle): NSUnderlineStyle.single.rawValue
        ]))

        btnSignin.layer.cornerRadius = 35 / 2
        btnSignin.layer.masksToBounds = true
        btnSignin.backgroundColor = UIColor.theme.button
        btnSignin.setTitleColor(UIColor.white, for: UIControl.State())

        btnFacebook.layer.cornerRadius = 35 / 2
        btnFacebook.layer.masksToBounds = true
        btnFacebook.backgroundColor = UIColor.theme.facebook
        btnFacebook.setTitleColor(UIColor.white, for: UIControl.State())

        termsLinkButton.setTitle("global.signUp.acceptRegister.terms".localized, for: .normal)
        policyLinkButton.setTitle("global.signUp.acceptRegister.privatePolicy".localized, for: .normal)

        termsLinkButton.tintColor = UIColor.theme.green
        policyLinkButton.tintColor = UIColor.theme.green
        termsLinkButton.setTitleColor(UIColor.theme.green, for: .normal)
        policyLinkButton.setTitleColor(UIColor.theme.green, for: .normal)

        UserManager.instance.delegate = self
    }

}

extension TutorialLastPageViewController: UserManagerDelegate {

    func userManagerSignWithApple(error: Error?) {
        guard error == nil else {
            print(error?.localizedDescription as Any)
            show(error: error!)
            return
        }

        guard let user = UserManager.instance.user else { return }
        print("Successful logged as \(user.email ?? "no email")")

        askPermissions { [weak self] in
            guard let main = self?.main() else { return }
            self?.changeRoot(viewController: main)
        }

        // Register notifications.
        NotificationsManager.registerNotifications()
    }

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {

	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {

	return input.rawValue

}
