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

import Foundation
import UIKit

open class Theme {

    public static var current = Theme()

    open var color: Color = Color()
    open var font: Font = Font()

    public init() {}

    // MARK: - Theme definitions

    open class Color {
        public init() {}

        open var navBar: UIColor = UIColor.init(rgba: "#8CC947")
        open var navBarText: UIColor = .white
        open var tabBar: UIColor = .white
        open var tabBarSelected: UIColor = UIColor.init(rgba: "#8CC947")
        open var separatorLine: UIColor = UIColor.init(rgba: "#dadada")
        open var green: UIColor = UIColor.init(rgba: "#8CC947")
        open var red: UIColor = UIColor.init(rgba: "#DE371C")
        open var orange: UIColor = UIColor.init(rgba: "#EA6B2D")
        open var yellow: UIColor = UIColor.init(rgba: "#FFDC00")
        open var lightGray: UIColor = .lightGray
        open var dimGray: UIColor = UIColor.init(rgba: "#8E8E8E")
        open var leadBlack: UIColor = UIColor.init(rgba: "#212121")
        open var domestic: UIColor = UIColor.init(rgba: "#B88854")
        open var automotive: UIColor = UIColor.init(rgba: "#567980")
        open var construction: UIColor = UIColor.init(rgba: "#FF904E")
        open var plastic: UIColor = UIColor.init(rgba: "#6DBAE1")
        open var electronic: UIColor = UIColor.init(rgba: "#35567B")
        open var organic: UIColor = UIColor.init(rgba: "#80A920")
        open var metal: UIColor = UIColor.init(rgba: "#D1D1D1")
        open var liquid: UIColor = UIColor.init(rgba: "#E0DB39")
        open var dangerous: UIColor = UIColor.init(rgba: "#FF4444")
        open var deadAnimals: UIColor = UIColor.init(rgba: "#C2660B")
        open var glass: UIColor = UIColor.init(rgba: "#0c874e")

        open var button: UIColor = UIColor.init(rgba: "#8BC34A")
        open var facebook: UIColor = UIColor.init(rgba: "#36549c")
    }

    open class Font {
        public init() {}

        open var boldTitle: UIFont = .boldSystemFont(ofSize: 22)
        open var title: UIFont = .systemFont(ofSize: 22)
        open var boldText: UIFont = .boldSystemFont(ofSize: 17)
        open var text: UIFont = .systemFont(ofSize: 17)
        open var subtext: UIFont = .systemFont(ofSize: 13)
    }

    // MARK: - Appearance

    open func setupAppearance() {
        UINavigationBar.appearance().barStyle = UIBarStyle.black // Removes hairline at the top of the bar
        UINavigationBar.appearance().barTintColor = color.navBar
        UINavigationBar.appearance().tintColor = color.navBarText
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: color.navBarText]
        UITabBar.appearance().alpha = 1
        UITabBar.appearance().isOpaque = true
        UITabBar.appearance().shadowImage = UIImage() // Removes hairline at the top of the bar
        UITabBar.appearance().backgroundImage = UIImage.from(color: .white)// Removes hairline at the top of the bar
        UITabBar.appearance().barTintColor = color.tabBar
        UITabBar.appearance().tintColor = color.tabBarSelected


        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = .white
            tabBarAppearance.shadowImage = UIImage()
            tabBarAppearance.backgroundImage = UIImage.from(color: .white)

            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = color.navBar
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: color.navBarText]
            navigationBarAppearance.shadowImage = UIImage()
            navigationBarAppearance.shadowColor = .clear

            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
    }

}

public extension UIFont {
    
    static var theme: Theme.Font {
        return Theme.current.font
    }
}

/*
 Inspired by https://github.com/yeahdongcn/UIColor-Hex-Swift
 */
public extension UIColor {

    static var theme: Theme.Color {
        return Theme.current.color
    }

    /**
     Create color using rgb(a) string.

     Starts with #, number of characters after '#' should be either 3, 4, 6 or 8
     */
    convenience init(rgba: String) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0

        if rgba.hasPrefix("#") {
            let index   = rgba.index(rgba.startIndex, offsetBy: 1)
            let hex     = String(rgba[index...])
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                switch hex.count {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                print("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

}
