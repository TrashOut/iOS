//
//  ContentPickerView.swift
//  TrashOut
//
//  Created by Juraj Macák on 29/08/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import UIKit

protocol ContentPickerDelegate: AnyObject {
    func contentPickerDidSelect(_ view: UIView, row: Int, value: String)
    func contentPickerDonePressed(_ view: UIView)
}

extension ContentPickerDelegate {
    func contentPickerDonePressed(_ view: UIView) {}
}

// MARK: - Class

final class ContentPickerView: ReusableNibView {

    private enum C {
        static let PICKER_HEIGHT: CGFloat = 220
    }

    struct Model {

        let cardLook: Bool
        let title: String
        let items: [String]

        init(cardLook: Bool = true, title: String, items: [String]) {
            self.cardLook = cardLook
            self.title = title
            self.items = items
        }

    }

    // MARK: - Outlet

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextfield: UITextField!
    @IBOutlet weak var wrapperView: Card!

    weak var delegate: ContentPickerDelegate?

    private var items: [String] = []

    // MARK: - Variable

    private var model: Model?

    // MARK: - Lifecycle

    required init?(coder: NSCoder) {
        super.init(coder: coder)


    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Setup

    func setup(_ model: Model) {
        self.model = model

        self.items = model.items
        titleLabel.text = model.title

        if model.cardLook {
            wrapperView.asCard()
        }

        setupDataPickerInputView(items: model.items)
    }

}

// MARK: - Private

extension ContentPickerView {

    private func setupDataPickerInputView(items: [String]) {
        let contentPickerView = ContentPickerInputView(frame: .init(x: .zero, y: .zero, width: frame.width, height: C.PICKER_HEIGHT))
        contentPickerView.setup(.init(items: items))
        contentPickerView.delegate = self

        valueTextfield.inputView = contentPickerView

    }

}

// MARK: - ContentPickerDelegate

extension ContentPickerView: ContentPickerDelegate {

    func contentPickerDidSelect(_ view: UIView, row: Int, value: String) {
        delegate?.contentPickerDidSelect(self, row: row, value: value)
    }

    func contentPickerDonePressed(_ view: UIView) {
        valueTextfield.resignFirstResponder()
    }

}
