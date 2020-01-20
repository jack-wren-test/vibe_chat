//
//  AuthenticationTextField.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

@IBDesignable
/// Custom text field for authentication controlls
public class AuthenticationTextField: UITextField {

    // MARK:- Properties
    
    private let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    @IBInspectable
    var placeholderTextColor: UIColor? {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeholderTextColor ?? UIColor.lightGray])
        }
    }
    
    let badInputIndicator: UIImageView = {
        let indicator = UIImageView(image: #imageLiteral(resourceName: "warningIcon"))
        indicator.tintColor = UIColor(named: "decoration")
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.isHidden = true
        return indicator
    }()
    
    // MARK:- Lifecycle
    
    public override func awakeFromNib() {
        addBadInputIndicator()
    }
    
    // MARK:- Methods
    
    private func addBadInputIndicator() {
        self.addSubview(badInputIndicator)
        
        self.badInputIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.badInputIndicator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        self.badInputIndicator.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.badInputIndicator.widthAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}
