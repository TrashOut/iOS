//
//  CleaningEventTableViewCell.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 06/02/2022.
//  Copyright © 2022 TrashOut NGO. All rights reserved.
//

import UIKit

class CleaningEventTableViewCell: UITableViewCell {

    @IBOutlet var lblHelpUsToCleanIt: UILabel!
    @IBOutlet var lblEventDate: UILabel!
    @IBOutlet var btnJoin: UIButton!
    @IBOutlet var btnDetail: UIButton!
    @IBOutlet var leadingSpaceToJoinBtn: NSLayoutConstraint!
    @IBOutlet var leadingSpaceToContainer: NSLayoutConstraint!

    override func prepareForReuse() {
        super.prepareForReuse()
        lblHelpUsToCleanIt.text = ""
        btnJoin.setTitle("", for: .normal)
        btnDetail.setTitle("", for: .normal)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        lblEventDate.textColor = Theme.current.color.lightGray
    }

}
