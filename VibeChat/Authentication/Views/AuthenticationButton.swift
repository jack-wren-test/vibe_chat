//
//  AuthenticationButton.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

@IBDesignable
public class AuthenticationButton: UIButton {

    // MARK:- Properties
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 60)
    }
    
    public override func titleColor(for state: UIControl.State) -> UIColor? {
        switch state {
        case .disabled:
            return UIColor.systemGray2
        default:
            return UIColor(named: "text_alt")
        }
    }
    
    // MARK:- AwakeFromNib
    
    public override func awakeFromNib() {
        layoutUI()
    }
    
    
    // MARK:- Methods
    
    fileprivate func layoutUI() {
        setTitleColor(UIColor(named: "text_alt"), for: .normal)
        setTitleColor(UIColor.systemGray2, for: .disabled)
        layer.borderColor = isEnabled ? UIColor(named: "text_alt")?.cgColor : UIColor.systemGray2.cgColor
    }
    
    public func toggleEnabledDisabled(isEnabled: Bool) {
        self.isEnabled = isEnabled
        layer.borderColor = isEnabled ? UIColor(named: "text_alt")?.cgColor : UIColor.systemGray2.cgColor
    }

}
