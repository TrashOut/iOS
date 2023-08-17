//
//  HistoryTableViewCell.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 06/02/2022.
//  Copyright © 2022 TrashOut NGO. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var ivHistoryStatusImage: UIImageView!
    @IBOutlet var lblHistoryUser: UILabel!
    @IBOutlet var lblHistoryStatus: UILabel!
    @IBOutlet var lblHistoryStatusDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        lblHistoryStatusDate.textColor = Theme.current.color.lightGray
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ivHistoryStatusImage.cancelRemoteImageRequest()
        lblHistoryUser.text = ""
        lblHistoryStatus.text = ""
        lblHistoryStatusDate.text = ""
    }

}

// MARK: - Public

extension HistoryTableViewCell {

    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {

        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }

}
