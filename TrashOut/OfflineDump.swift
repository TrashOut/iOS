//
//  OfflineDump.swift
//  TrashOut
//
//  Created by Juraj Macák on 26/07/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import UIKit

struct OfflineDump: Codable, Equatable {

    let imagesData: [Data]
    let gps: Coordinates
    let size: String
    let type: [String]
    let note: String?
    let anonymous: Bool
    let userId: Int
    let accessibility: DumpsAccessibility

    var localImages: [LocalImage] {
        return imagesData
            .map { UIImage(data: $0) }
            .compactMap { $0 }
            .map { image in
                let localImage = LocalImage()
                localImage.uid = UUID().uuidString
                localImage.image = image
                localImage.store = .temp

                return localImage
            }
    }

}
