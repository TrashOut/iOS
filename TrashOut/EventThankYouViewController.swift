//
// TrashOut
// Copyright 2017 TrashOut NGO. All rights reserved.
// License GNU GPLv3
//

/**
  * TrashOut is an environmental project that teaches people how to recycle
  * and showcases the worst way of handling waste - illegal dumping. All you need is a smart phone.
  *
  *
  * There are 10 types of programmers - those who are helping TrashOut and those who are not.
  * Clean up our code, so we can clean up our planet.
  * Get in touch with us: help@trashout.ngo
  *
  * Copyright 2017 TrashOut, n.f.
  *
  * This file is part of the TrashOut project.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * See the GNU General Public License for more details: <https://www.gnu.org/licenses/>.
 */

import UIKit

class EventThankYouViewController: UIViewController {

    @IBOutlet var lblClaimTop: UILabel!
    @IBOutlet var lblClaimBotton: UILabel!
    @IBOutlet var btnShare: UIButton!
    
    var event: Event?
    
    var dismissHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "trash.create.thankYou.title".localized
        lblClaimTop.text = "event.create.thankYou.sentence1".localized + "\n" + "event.create.thankYou.sentence2".localized
        lblClaimBotton.text = "event.create.thankYou.sentence3".localized
        btnShare.setTitle("event.create.thankYou.shareTitle".localized.uppercased(with: .current), for: .normal)
        btnShare.theme()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            dismissHandler?()
        }
    }

    @IBAction func shareButtonTapped() {
        guard let id = event?.id else { return }
        let url = Link.event(id: id).url
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }
}
