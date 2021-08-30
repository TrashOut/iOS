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

        init(cardLook: Bool = true, title: String) {
            self.cardLook = cardLook
            self.title = title
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

    override func awakeFromNib() {
        super.awakeFromNib()

        valueTextfield.isUserInteractionEnabled = false
    }

    // MARK: - Setup

    func setup(_ model: Model) {
        self.model = model

        titleLabel.text = model.title
        valueTextfield.font = Theme.Font().boldTitle

        if model.cardLook {
            wrapperView.asCard()
        }
    }

    func add(items: [String]) {
        self.items = items

        setupDataPickerInputView(items: items)
        valueTextfield.isUserInteractionEnabled = items.count > 1

        valueTextfield.text = items.first
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

        valueTextfield.text = items[row]
    }

    func contentPickerDonePressed(_ view: UIView) {
        valueTextfield.resignFirstResponder()
    }

}
