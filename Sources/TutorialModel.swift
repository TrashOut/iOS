//
//  TutorialModel.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 29.03.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit

class TutorialPage {

	var title: String?
	var content: String?
	var image: UIImage?

	init(title: String?, content: String?, image: UIImage?) {
		self.title = title
		self.content = content
		self.image = image
	}

}

class Tutorial {
    
	var pages: [TutorialPage] = [
		TutorialPage.init(title: "tutorial.title.1".localized, content: "tutorial.text.1".localized, image: UIImage.init(named: "tutorial-1")),
		TutorialPage.init(title: "tutorial.title.2".localized, content: "tutorial.text.2".localized, image: UIImage.init(named: "tutorial-2")),
		TutorialPage.init(title: "tutorial.title.3".localized, content: "tutorial.text.3".localized, image: UIImage.init(named: (UIDevice.current.screenType == .iPhones_5_5s_5c_SE || UIDevice.current.screenType == .iPhone4_4S) ? "tutorial-3-SE"  : "tutorial-3")),
		TutorialPage.init(title: "tutorial.title.4".localized, content: "tutorial.text.4".localized, image: UIImage.init(named: "tutorial-4")),
		TutorialPage.init(title: "tutorial.title.5".localized, content: "tutorial.text.5".localized, image: UIImage.init(named: "tutorial-5"))
	]
    
    func getImageAccordingToDevice() {
        
        
        
        /*
        if Device.type == .iPhone8plus {
            
        }*/
    }
}
