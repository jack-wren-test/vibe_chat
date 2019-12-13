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
            return UIColor.lightGray
        default:
            return UIColor.appDark
        }
    }
    
    // MARK:- AwakeFromNib
    
    public override func awakeFromNib() {
        layoutUI()
    }
    
    
    // MARK:- Methods
    
    fileprivate func layoutUI() {
        setTitleColor(.appDark, for: .normal)
        setTitleColor(.lightGray, for: .disabled)
        layer.borderColor = self.isEnabled ? UIColor.appDark.cgColor : UIColor.lightGray.cgColor
    }
    
    public func toggleEnabledDisabled(isEnabled: Bool) {
        self.isEnabled = isEnabled
        layer.borderColor = isEnabled ? UIColor.appDark.cgColor : UIColor.lightGray.cgColor
    }

}
