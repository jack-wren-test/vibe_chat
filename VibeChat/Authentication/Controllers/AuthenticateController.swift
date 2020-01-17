//
//  CanAuthenticateController.swift
//  VibeChat
//
//  Created by Jack Smith on 15/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

/// Base class for controllers with the ability to authenticate a user.
class AuthenticateController: UIViewController {
    
    // MARK:- Properties
    
    weak var delegate: LoginDelegate?
    var formKeyboardHiddenYConstraint: NSLayoutConstraint?
    var formKeyboardVisibleYConstraint: NSLayoutConstraint?
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForKeyboardWillShow()
        self.registerForKeyboardWillHide()
        self.setupTapToDismissKeyboard()
    }
    
    deinit {
        print("Log in controller deinitialized")
    }
    
    // MARK:- Methods
    
    public func checkPasswordIsComplex(password: String) -> Bool {
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        guard texttest.evaluate(with: password) else { return false }

        let numberRegEx  = ".*[0-9]+.*"
        let texttest1 = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        guard texttest1.evaluate(with: password) else { return false }

        let length  = password.count >= 8
        guard length else {return false}

        return true
    }
    
    @objc public override func keyboardWillShow(_ notification: Notification) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.animateViewWithKeyboard(notification)
        }
    }
    
    @objc public override func keyboardWillHide(_ notification: Notification) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIView.animate(withDuration: 0.5) {
                self.formKeyboardVisibleYConstraint?.isActive = false
                self.formKeyboardHiddenYConstraint?.isActive = true
                self.view.layoutIfNeeded()
            }
        }
    }

}
