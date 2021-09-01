//
//  ContentPickerInputView.swift
//  TrashOut
//
//  Created by Juraj Macák on 29/08/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import UIKit

// MARK: - Class

final class ContentPickerInputView: ReusableNibView {

    enum C {
        static let NUMBER_OF_COMPONENTS = 1
    }

    struct Model {
        let items: [String]
    }

    // MARK: - Outlet

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    weak var delegate: ContentPickerDelegate?

    // MARK: - Variable

    private var model: Model?
    private var items: [String] = []

    // MARK: - Setup

    func setup(_ model: Model) {
        self.model = model
        self.items = model.items

        setupStyle()
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        delegate?.contentPickerDonePressed(self)
    }

}

// MARK: - Private

extension ContentPickerInputView {

    private func setupStyle() {
        doneButton.tintColor = Theme.Color().green
    }

}

extension ContentPickerInputView: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return C.NUMBER_OF_COMPONENTS
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        items.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.contentPickerDidSelect(self, row: row, value: items[row])
    }

}
