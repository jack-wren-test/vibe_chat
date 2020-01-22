//
//  LogInController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Controller for log in screen.
final class LogInController: AuthenticateController {
    
    // MARK:- IBOulets
    
    @IBOutlet public weak var formRulesTextView: UITextView!
    @IBOutlet public weak var emailTF: AuthenticationTextField!
    @IBOutlet public weak var passwordTF: AuthenticationTextField!
    @IBOutlet public weak var form: UIStackView!
    @IBOutlet public weak var authenticateButton: AuthenticationButton!
    
    // MARK:- Properties
    
    let formRulesText = ""
    
    override var borderColour: CGColor? {
        didSet {
            guard let borderColour = borderColour else {return}
            authenticateButton.layer.borderColor = authenticateButton.isEnabled ? borderColour : UIColor.systemGray2.cgColor
        }
    }
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTextFieldDidChangeActions()
        if self.formKeyboardHiddenYConstraint == nil {
            self.formKeyboardHiddenYConstraint = form.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            self.formKeyboardHiddenYConstraint?.isActive = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.emailTF.becomeFirstResponder()
    }
    
    // MARK:- IBActions
    
    @IBAction private func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func LogInButtonPressed(_ sender: AuthenticationButton) {
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13, *), self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            borderColour = UIColor(named: "text_alt")?.cgColor
        }
    }
    
}
