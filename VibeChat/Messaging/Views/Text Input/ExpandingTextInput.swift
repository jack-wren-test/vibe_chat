//
//  ExpandingTextInput.swift
//  VibeChat
//
//  Created by Jack Smith on 20/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

@IBDesignable
/// Custom text input with self exapnding functionality.
class ExpandingTextInput: UITextView {
    
    // MARK:- Properties
    
    private let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    private let placeholderText = "Type message..."
    private let placeholderLabel = UILabel()
    
    @IBInspectable
    var placeholderTextColor: UIColor? {
        didSet {
            self.placeholderLabel.attributedText = NSAttributedString(string: self.placeholderText, attributes: [NSAttributedString.Key.foregroundColor : placeholderTextColor ?? UIColor.lightGray])
        }
    }
    
    
    // MARK:- Lifecycle
    
    public override func awakeFromNib() {
        addPlaceholder()
    }
    
    // MARK:- Methods
    
    private func addPlaceholder() {
        addSubview(placeholderLabel)
        let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textContainerInset = padding
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
    }
    
    public func hidePlaceholder() {
        placeholderLabel.isHidden = true
    }
    
    public func showPlaceholder() {
        placeholderLabel.isHidden = false
    }
    
    public func scrollToBottom() {
        let bottom = self.contentSize.height - self.frame.height
        self.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
    }
    
}
