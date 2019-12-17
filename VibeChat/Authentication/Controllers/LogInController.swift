//
//  LogInController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class LogInController: AuthenticationController {
    
    // MARK:- IBOulets
    
    @IBOutlet weak var emailTF: AuthenticationTextField!
    @IBOutlet weak var passwordTF: AuthenticationTextField!
    @IBOutlet weak var form: UIStackView!
    @IBOutlet weak var authenticateButton: AuthenticationButton!
    
    // MARK:- Properties
    
    var formKeyboardHiddenYConstraint: NSLayoutConstraint?
    var formKeyboardVisibleYConstraint: NSLayoutConstraint?
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardWillShow()
        registerForKeyboardWillHide()
        registerForKeyboardWillChange()
        setupTapToDismissKeyboard()
        addTextFieldDidChangeActions()
        emailTF.becomeFirstResponder()
        if formKeyboardHiddenYConstraint == nil {
            formKeyboardHiddenYConstraint = form.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            self.formKeyboardHiddenYConstraint?.isActive = true
        }
    }
    
    // MARK:- Deinit
    
    deinit {
        print("Log in controller deinitialized")
    }
    
    // MARK:- IBActions
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func LogInButtonPressed(_ sender: AuthenticationButton) {
        performAuthentication()
    }
    
    // MARK:- Methods
    
    override func animateViewWithKeyboard(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            formKeyboardVisibleYConstraint?.isActive = false
            formKeyboardVisibleYConstraint = form.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(keyboardHeight+30))
            UIView.animate(withDuration: 0.5) {
                self.formKeyboardHiddenYConstraint?.isActive = false
                self.formKeyboardVisibleYConstraint?.isActive = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK:- ObjC Methods
    
    @objc public override func keyboardWillShow(_ notification: Notification) {
        animateViewWithKeyboard(notification)
    }
    
    @objc public override func keyboardWillChange(_ notification: Notification) {
        animateViewWithKeyboard(notification)
    }
    
    @objc public override func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.formKeyboardVisibleYConstraint?.isActive = false
            self.formKeyboardHiddenYConstraint?.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
}

extension LogInController: CanAuthenticate {
    
    func addTextFieldDidChangeActions() {
        form.subviews[0].subviews.forEach { (view) in
            if let tf = view as? AuthenticationTextField {
                tf.addTarget(self, action: #selector(enableAuthenticateButtonIfNeeded), for: .editingChanged)
            }
        }
    }
    
    func performAuthentication() {
        if let email = emailTF.text,
            let password = passwordTF.text {
            CurrentUser.shared.logIn(withEmail: email, andPassword: password) {
                self.presentHomeScreen()
            }
        }
    }
    
    func isFormValid() -> Bool {
        if let _ = emailTF.text,
            let password = passwordTF.text {
            return checkPasswordIsComplex(password: password)
        }
        return false
    }
    
    @objc func enableAuthenticateButtonIfNeeded() {
        authenticateButton.toggleEnabledDisabled(isEnabled: isFormValid())
    }
    
}
