//
//  OfflineDumpManager.swift
//  OfflineDumpManager
//
//  Created by Juraj Macák on 27/07/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import Foundation
import PromiseKit

class OfflineDumpManager {

    private var successfullUploadedDumps = [OfflineDump]()
    var didUploadOfflineDump: VoidClosure?

}

// MARK: - Public

extension OfflineDumpManager: OfflineDumpManagerType {

    func uploadOfflineDumps() {
        self.successfullUploadedDumps.removeAll()
        let dumps = CacheManager.shared.offlineDumps
        guard Reachability.isConnectedToNetwork(), dumps.count > 0 else { return } // In case internet connection is not established, nothing happend

        let uploadRequestPromises: [Promise<Void>] = dumps.map { dump in
            let uploadImagesChain = dump.localImages
                .map { [weak self] localImage in self?.upload(photo: localImage) }
                .compactMap { $0 }

            return when(fulfilled: uploadImagesChain)
                .then { [unowned self] dumpImages in self.upload(dump: dump, images: dumpImages) }
        }

        when(fulfilled: uploadRequestPromises)
            .done { [weak self] in
                self?.didUploadOfflineDump?()
            }
            .ensure { [weak self] in
                self?.updateCache()
            }
            .catch { error in
                // TODO: Track fails
            }
    }

}

// MARK: - Private

extension OfflineDumpManager {

    private func updateCache() {
        let offlineDumps = CacheManager.shared.offlineDumps.filter { [weak self] in
            self?.successfullUploadedDumps.contains($0) ?? false
        }

        CacheManager.shared.offlineDumps = offlineDumps
    }

    private func upload(dump: OfflineDump, images: [DumpsImages]) -> Promise<Void> {
        return Promise { seal in
            Networking.instance.createTrash(images, gps: dump.gps, size: dump.size, type: dump.type, note: dump.note, anonymous: dump.anonymous, userId: (UserManager.instance.user?.id)!, accessibility: dump.accessibility) { [weak self] (trash, error) in
                guard let error = error else {
                    self?.successfullUploadedDumps.append(dump)
                    seal.fulfill(())
                    return
                }
                seal.reject(error)
            }
        }
    }

    private func upload(photo: LocalImage) -> Promise<DumpsImages> {
        return Promise { seal in
            guard let photoName = photo.uid, let data = photo.jpegData, let thumbnailData = photo.thumbnailJpegData else {
                seal.reject(OfflineDumpError.uploadImageFailed)
                return
            }

            FirebaseImages.instance.uploadImage(photoName, data: data, thumbnailData: thumbnailData) { (thumbnailUrl, thumbnailStorage , imageUrl, imageStorage, error) in
                guard error == nil else {
                    print(error?.localizedDescription as Any)
                    if let error = error {
                        seal.reject(error)
                    }
                    return
                }
                guard let thumbnailUrl = thumbnailUrl else {
                    let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
                    seal.reject(error)
                    return
                }
                guard let thumbnailStorage = thumbnailStorage else {
                    let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
                    seal.reject(error)
                    return
                }
                guard let imageUrl = imageUrl else {
                    let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
                    seal.reject(error)
                    return
                }
                guard let imageStorage = imageStorage else {
                    let error = NSError.init(domain: "cz.trashout.TrashOut", code: 500, userInfo: [NSLocalizedDescriptionKey: "global.validation.unknownError".localized])
                    seal.reject(error)
                    return
                }

                seal.fulfill(.init(thumbDownloadUrl: thumbnailUrl, thumbStorageLocation: thumbnailStorage, fullDownloadUrl: imageUrl, storageLocation: imageStorage))
            }
        }
    }

}

// MARK: - OfflineDumpError

enum OfflineDumpError: Error {
    case uploadImageFailed
}
