//
//  UIView+.swift
//  TrashOut
//
//  Created by Juraj Macák on 30/08/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import UIKit

extension UIView {

    static func loadFromNib() -> Self {
        return loadNib(self)
    }

    // swiftlint:disable force_cast

    static func loadNib<A>(_ owner: AnyObject, bundle: Bundle = Bundle.main) -> A {
        guard let nibName = NSStringFromClass(classForCoder()).components(separatedBy: ".").last else {
            fatalError("Class name [\(NSStringFromClass(classForCoder()))] has no components.")
        }

        guard let nib = bundle.loadNibNamed(nibName, owner: owner, options: nil) else {
            fatalError("Nib with name [\(nibName)] doesn't exists.")
        }
        for item in nib {
            if let item = item as? A {
                return item
            }
        }
        return nib.last as! A
    }

}

extension UIView {

    func pinNibContent() {
        let content = getUINib().instantiate(withOwner: self, options: nil)
        guard let view = content.first as? UIView else {
            assert(false, "Unable to load nib content")
            return
        }
        pinSubview(view)
    }

    func getUINib() -> UINib {
        let nibName = String(describing: type(of: self))
        return UINib(nibName: nibName, bundle: nil)
    }

    func pinSubview(_ subview: UIView, at index: Int? = nil) {
        subview.translatesAutoresizingMaskIntoConstraints = false

        if let index = index {
            insertSubview(subview, at: index)
        } else {
            addSubview(subview)
        }

        let views = ["v": subview]
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[v]|", metrics: nil, views: views)
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[v]|", metrics: nil, views: views)
        NSLayoutConstraint.activate(vertical + horizontal)
    }

    func insertSubviews(_ subview: UIView, padding: CGFloat = 0.0) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        subview.topAnchor.constraint(equalTo: self.topAnchor, constant: padding).isActive = true
        subview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding).isActive = true
        subview.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding).isActive = true
        subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding).isActive = true
    }

}

class ReusableNibView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        pinNibContent()
        awake()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        pinNibContent()
        awake()
    }

    func awake() {

    }

}
