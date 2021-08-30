//
//  Instantiable+.swift
//  TrashOut
//
//  Created by Juraj Macák on 29/08/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import UIKit

protocol NameDescribable {
    var typeName: String { get }
    static var typeName: String { get }
}

extension NameDescribable {
    var typeName: String {
        return String(describing: type(of: self))
    }

    static var typeName: String {
        return String(describing: self)
    }
}

extension NSObject: NameDescribable {}
extension Array: NameDescribable {}

protocol Instantiable {
    static func makeInstance(name: String?) -> Self
}

extension Instantiable where Self: UIViewController {
    /// Instantiates controller from storyboard.
    /// - example:
    /// `let myViewController = MyViewController.makeInstance()`
    /// - important:
    /// Initial controller of the same type must exists in storyboard named as controller's
    /// class without "ViewController" suffix, otherwise will `fatalError()`.
    /// - Returns: Instantiated view controller.
    static func makeInstance(name: String? = nil) -> Self {
        var viewControllerName: String
        if let name = name {
            viewControllerName = name
        } else {
            viewControllerName = typeName
        }

        let storyboard = UIStoryboard(name: viewControllerName, bundle: nil)
        guard let instance =
            storyboard.instantiateInitialViewController() as? Self
            else { fatalError("Could not make instance of \(String(describing: self))") }
        return instance
    }
}

extension UIViewController: Instantiable {}

