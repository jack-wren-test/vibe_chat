//
//  CreateAccountController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Controller for create account screen.
final class CreateAccountController: AuthenticateController {
    
    // MARK:- IBOutlets
    
    @IBOutlet public weak var formRulesTextView: UITextView!
    @IBOutlet public weak var nameTF: AuthenticationTextField!
    @IBOutlet public weak var emailTF: AuthenticationTextField!
    @IBOutlet public weak var passwordTF: AuthenticationTextField!
    @IBOutlet public weak var passwordConfirmTF: AuthenticationTextField!
    @IBOutlet public weak var form: UIStackView!
    @IBOutlet public weak var authenticateButton: AuthenticationButton!
    
    // MARK:- Properties
    
    let formRulesText = "Your password must be at least 8 characters long, contain at least one uppercase letter, and contain at least one number."
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTextFieldDidChangeActions()
        if self.formKeyboardHiddenYConstraint == nil {
            self.formKeyboardHiddenYConstraint = self.form.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            self.formKeyboardHiddenYConstraint?.isActive = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.nameTF.becomeFirstResponder()
    }
    
    deinit {
        print("Create account controller deinitialized")
    }

    // MARK:- IBActions
    
    @IBAction private func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func createAccountButtonPressed(_ sender: AuthenticationButton) {
        self.performAuthentication()
    }
    
    // MARK:- Methods
    
    override func animateViewWithKeyboard(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.formKeyboardVisibleYConstraint?.isActive = false
            self.formKeyboardVisibleYConstraint = form.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                               constant: -(keyboardHeight+20))
            let animationDuration = 0.5
            UIView.animate(withDuration: animationDuration) {
                self.formKeyboardHiddenYConstraint?.isActive = false
                self.formKeyboardVisibleYConstraint?.isActive = true
                self.view.layoutIfNeeded()
            }
        }
    }

}
