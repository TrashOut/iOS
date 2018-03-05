//
//  ReportThankYouViewController.swift
//  TrashOut
//
//  Created by Lukáš Andrlik on 29/11/2017.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import EventKit

class ReportThankYouViewController: ViewController {

    @IBOutlet var lblClaimTop: UILabel!
    @IBOutlet var lblClaimBotton: UILabel!
    @IBOutlet var btnShare: UIButton!
    
    var trash: Trash? {
        didSet {
        }
    }
    
    var dismissHandler:(()->Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "trash.create.thankYou.title".localized
        lblClaimTop.text = "trash.create.thankYou.sentence1".localized + " " + "trash.create.thankYou.sentence2".localized
        lblClaimBotton.text = "trash.create.thankYou.sentence3".localized
        btnShare.setTitle("trash.create.thankYou.shareTitle".localized.uppercased(with: .current), for: .normal)
        btnShare.theme()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (self.dismissHandler != nil) && self.isMovingFromParentViewController {
            dismissHandler()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Share

    @IBAction func shareButtonTapped() {
        guard let id = trash?.id else { return }
        let message = "https://admin.trashout.ngo/trash-management/detail/" + String(id)
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }
    
}
