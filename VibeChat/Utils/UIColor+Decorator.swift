//
//  UIColor+Decorator.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static var appPrimary = UIColor(r: 248, g: 112, b: 96)
    static var appLight = UIColor(r: 255, g: 255, b: 255)
    static var appDark = UIColor(r: 16, g: 37, b: 66)
    static var appHighlight1 = UIColor(r: 205, g: 215, b: 214)
    static var appHighlight2 = UIColor(r: 179, g: 163, b: 148)
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}
