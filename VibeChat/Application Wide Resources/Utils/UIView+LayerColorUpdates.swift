//
//  UIView+LayerColorUpdates.swift
//  VibeChat
//
//  Created by Jack Smith on 22/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension UIViewController {
    
    private struct layerColour {
        static var colour: CGColor?
    }
    
    @objc public var borderColour: CGColor? {
        get {
            return layerColour.colour
        }
        set {
            layerColour.colour = newValue
        }
    }
    
}
