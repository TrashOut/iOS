//
//  TestingViewController.swift
//  TrashOut
//
//  Created by Miroslav Poživil on 07/11/2016.
//  Copyright © 2016 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit

class TestDetailViewController: ViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var lastView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var heightContraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var viewToHide: UIView! {
        didSet {
            viewToHide.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        heightContraint.constant = 200
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hideTheView(_ sender: Any) {
        viewToHide.isHidden = !viewToHide.isHidden
    }
    
    @IBAction func showTheView(_ sender: Any) {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TypeCell", for: indexPath) as? TestCollectionViewCell else { fatalError("Could not dequeue cell with identifier: GalleryCell") }
        
        cell.lblType.text = "KANCI"
        cell.ivImage.backgroundColor = .red
        
        return cell
    }
    
}

class TestCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var ivImage: UIImageView!
    
    @IBOutlet var lblType: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivImage.cancelRemoteImageRequest()
    }
    
}
