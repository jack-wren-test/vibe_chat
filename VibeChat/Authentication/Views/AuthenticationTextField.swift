//
//  AuthenticationTextField.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

@IBDesignable
public class AuthenticationTextField: UITextField {

    // MARK:- Properties
    
    @IBInspectable
    var placeholderTextColor: UIColor? {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeholderTextColor ?? UIColor.lightGray])
        }
    }

}
