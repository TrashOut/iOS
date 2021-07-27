//
//  UIViewController+.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 26/07/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import UIKit

typealias VoidClosure = () -> Void

extension UIViewController {

    /// Present simple Alert Controller with custom title and message
    /// - Parameters:
    ///   - title: Alert Title
    ///   - message: Alert message
    ///   - style: Both Alert, or Bottom sheet support
    ///   - completion: Called after alert dismiss
    func presentSimpleAlert(title: String?, message: String?, style: UIAlertController.Style = .alert, completion: VoidClosure? = nil) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "global.close".localized, style: .cancel, handler: nil)
        controller.addAction(action)

        present(controller, animated: true, completion: completion)
    }

}
