//
//  NSAtrributedString+.swift
//  TrashOut-Prod
//
//  Created by Juraj Macák on 18/05/2021.
//  Copyright © 2021 TrashOut NGO. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {

    /// Convert specific part of text into clickable link with provided linkURL string
    /// - Parameters:
    ///   - textToFind: Part of text converted into clickable link
    ///   - linkURL: string URL
    public func setAsLink(textToFind:String, linkURL:String) {
        let foundRange = self.mutableString.range(of: textToFind)

        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
        }
    }

}
