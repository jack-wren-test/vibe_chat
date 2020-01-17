//
//  CreateAccountController+CanAuthenticate.swift
//  VibeChat
//
//  Created by Jack Smith on 15/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension CreateAccountController: CanAuthenticateWithForm {
    
    func addTextFieldDidChangeActions() {
        self.form.subviews[0].subviews.forEach { (view) in
            if let tf = view as? AuthenticationTextField {
                tf.addTarget(self, action: #selector(self.enableAuthenticateButtonIfNeeded), for: .editingChanged)
            }
        }
    }
    
    func performAuthentication() {
        guard let fields = self.getTextFromFields() else { return }
        AuthenticationManager.shared.createVibeChatAccount(name: fields.name,
                                                           email: fields.email,
                                                           password: fields.password) { [weak self] (error)  in
            guard let self = self else {return}
            if let error = error {
                self.handleFailedToAuthenticate(error: error)
            } else {
                self.dismiss(animated: true) {
                    self.delegate?.presentHomeScreen(true)
                }
            }
        }
    }
    
    func isFormValid() -> Bool {
        if nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "",
        emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "",
            let password = self.passwordTF.text,
            let passwordConfirm = self.passwordConfirmTF.text,
            password == passwordConfirm {
            return self.checkPasswordIsComplex(password: password)
        }
        return false
    }
    
    fileprivate func getTextFromFields() -> (name: String, email: String, password: String)? {
        if let name = self.nameTF.text,
            let email = self.emailTF.text,
            let password = self.passwordTF.text {
            return (name: name , email: email, password: password)
        }
        return nil
    }
    
    @objc func enableAuthenticateButtonIfNeeded() {
        self.emailTF.badInputIndicator.isHidden = true
        self.authenticateButton.toggleEnabledDisabled(isEnabled: isFormValid())
    }
    
}

