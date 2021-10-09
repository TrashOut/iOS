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

    enum C {
        static let offlineUploadErrorMessage = "Error with uploading offline dump"
    }

    private var successfullUploadedDumps = [OfflineDump]()

}

// MARK: - Public

extension OfflineDumpManager: OfflineDumpManagerType {

    /// Send offline reports from cache into servers
    ///
    /// Upload process will start immediately after internet connection is esthablished and cache contains dump at least with one item.
    ///
    /// - Parameter completion: Result completion handler
    func uploadCachedOfflineDumps(completion: TrashOptionalClosure? = nil) {
        self.successfullUploadedDumps.removeAll()
        let dumps = CacheManager.shared.offlineDumps
        guard Reachability.isConnectedToNetwork(), dumps.count > 0 else {
            completion?(nil)
            return
        } // In case internet connection is not established, nothing happend

        let uploadRequestPromises: [Promise<Trash?>] = dumps.map { dump in
            let uploadImagesChain = dump.localImages
                .map { [weak self] localImage in self?.upload(photo: localImage) }
                .compactMap { $0 }

            return when(fulfilled: uploadImagesChain)
                .then { [unowned self] dumpImages in self.upload(dump: dump, images: dumpImages) }
        }

        when(fulfilled: uploadRequestPromises)
            .done { result in completion?(result.first ?? nil) } // If multiple Trash request, get object of first trash from array which will be used in Thank you message
            .ensure { [weak self] in self?.updateCache() }
            .catch { error in
                FirebaseCrashlytics.track(customMessage: "\(C.offlineUploadErrorMessage) ERROR: \(error.localizedDescription)")
                completion?(nil)
            }
    }

}

// MARK: - Private

extension OfflineDumpManager {

    /// Update Offline dumps cache
    ///
    /// In case any offline dum was not successfull uploaded on the server, it will still persist in the temporary cache and on next offline dump upload it will try to upload again.
    ///
    private func updateCache() {
        let offlineDumps = CacheManager.shared.offlineDumps.filter { [weak self] in
            self?.successfullUploadedDumps.contains($0) ?? false
        }

        CacheManager.shared.offlineDumps = offlineDumps
    }

    /// Upload offline cached dump online
    /// - Parameters:
    ///   - dump: Dump object
    ///   - images: Dump images
    /// - Returns: empty Promise
    private func upload(dump: OfflineDump, images: [DumpsImages]) -> Promise<Trash?> {
        return Promise { seal in
            Networking.instance.createTrash(images, gps: dump.gps, size: dump.size, type: dump.type, note: dump.note, anonymous: dump.anonymous, userId: (UserManager.instance.user?.id)!, accessibility: dump.accessibility, organizationId: dump.organizationId) { [weak self] (trash, error) in
                guard let error = error else {
                    self?.successfullUploadedDumps.append(dump)
                    seal.fulfill(trash)
                    return
                }
                seal.reject(error)
            }
        }
    }

    /// Upload photo in the server
    /// - Parameter photo: Local cached dump photos
    /// - Returns: Promise with DumpsImages, which consist URL link to photo
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
