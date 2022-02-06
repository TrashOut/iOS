//
//  HistoryPhotoCollectionViewCell.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 06/02/2022.
//  Copyright © 2022 TrashOut NGO. All rights reserved.
//

import UIKit

class HistoryPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var ivPhoto: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        ivPhoto.cancelRemoteImageRequest()
    }

}
