//
//  TrashTypoCollectionViewCell.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 06/02/2022.
//  Copyright © 2022 TrashOut NGO. All rights reserved.
//

import UIKit

class TrashTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet var ivImage: UIImageView!
    @IBOutlet var lblTypeOfTrash: UILabel!
    @IBOutlet var cnImageHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        lblTypeOfTrash.textColor = Theme.current.color.lightGray

        ivImage.layer.cornerRadius = cnImageHeight.constant / 2
        ivImage.layer.masksToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ivImage.cancelRemoteImageRequest()
        lblTypeOfTrash.text = ""
    }

}
