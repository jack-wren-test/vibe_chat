//
//  CircularImageView.swift
//  VibeChat
//
//  Created by Jack Smith on 10/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

@IBDesignable
/// Custom image view for displaying profile images.
class CircularImageView: UIImageView {
    
    // MARK:- Properties

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

}
