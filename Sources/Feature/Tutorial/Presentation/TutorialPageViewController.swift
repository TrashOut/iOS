//
//  TutorialPageViewController.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 29.03.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit

class TutorialPageViewController: ViewController {

	@IBOutlet var ivImage: UIImageView!
	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var lblText: UILabel!
	@IBOutlet var btnSkip: UIButton!
	@IBOutlet var pageControl: UIPageControl!
	
	var page: TutorialPage?
	var index: Int = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		ivImage.image = page?.image
		lblTitle.text = page?.title
		lblText.text = page?.content
		pageControl.currentPage = index
	}
    
	@IBAction func skip() {
		guard let vc = self.parent?.parent as? TutorialViewController else { return }
		vc.skip()
	}
}
