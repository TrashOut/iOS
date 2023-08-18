//
//  ContentPickerTableViewCell.swift
//  TrashOut
//
//  Created by Juraj Macák on 29/08/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import UIKit

// MARK: - Class

final class ContentPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var contentXib: ContentPickerView!

    func setup(model: ContentPickerView.Model) {
        contentXib.setup(model)
    }

}
