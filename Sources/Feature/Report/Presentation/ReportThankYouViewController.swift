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
    @IBOutlet var btnDetail: UIButton!
    
    var trash: Trash?
    
    var dismissHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "trash.create.thankYou.title".localized
        lblClaimTop.text = "trash.create.thankYou.sentence1".localized + "\n" + "trash.create.thankYou.sentence2".localized
        lblClaimBotton.text = "trash.create.thankYou.sentence3".localized
        btnShare.setTitle("trash.create.thankYou.shareTitle".localized.uppercased(with: .current), for: .normal)
        btnShare.theme()
        btnDetail.setTitle("trash.create.thankYou.detail".localized.uppercased(with: .current), for: .normal)
        btnDetail.theme()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            dismissHandler?()
        }
    }

    @IBAction func shareButtonTapped() {
        guard let id = trash?.id else { return }
        let url = Link.dump(id: id).url
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func detailButtonTapped() {
        guard let id = trash?.id else { return }
        let detailVC = UIStoryboard(name: "Dumps", bundle: .main).instantiateViewController(withIdentifier: "DumpsDetailViewController") as! DumpsDetailViewController
        detailVC.id = id
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
