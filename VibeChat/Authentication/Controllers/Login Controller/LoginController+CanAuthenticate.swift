//
//  LoginController+CanAuthenticate.swift
//  VibeChat
//
//  Created by Jack Smith on 15/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension LogInController: CanAuthenticateWithForm {
    
    func addTextFieldDidChangeActions() {
        self.form.subviews[0].subviews.forEach { (view) in
            if let tf = view as? AuthenticationTextField {
                tf.addTarget(self, action: #selector(self.enableAuthenticateButtonIfNeeded), for: .editingChanged)
            }
        }
    }
    
    func performAuthentication() {
        guard let fields = self.getTextFromFields() else { return }
        CurrentUser.shared.logIn(withEmail: fields.email,
                                 andPassword: fields.password) { [weak self] (error) in
            guard let self = self else {return}
            if let error = error {
                self.handleFailedToAuthenticate(error: error)
            } else {
                self.dismiss(animated: true) {
                    self.delegate?.presentHomeScreen(false)
                }
            }
        }
    }
    
    func isFormValid() -> Bool {
        if self.emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "",
            let password = self.passwordTF.text {
            return self.checkPasswordIsComplex(password: password)
        }
        return false
    }
    
    fileprivate func getTextFromFields() -> (email: String, password: String)? {
        if let email = self.emailTF.text,
            let password = self.passwordTF.text {
            return (email: email, password: password)
        }
        return nil
    }
    
    @objc func enableAuthenticateButtonIfNeeded() {
        self.emailTF.badInputIndicator.isHidden = true
        self.authenticateButton.toggleEnabledDisabled(isEnabled: isFormValid())
    }
    
}

