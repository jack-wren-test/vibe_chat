//
//  CanAuthenticate.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Protocol and default implementations for log in and create account view controllers.
protocol CanAuthenticateWithForm {
    var formRulesTextView: UITextView! { get }
    var emailTF: AuthenticationTextField! { get }
    var formRulesText: String { get }
    
    func isFormValid() -> Bool
    func performAuthentication()
    func addTextFieldDidChangeActions()
    func enableAuthenticateButtonIfNeeded()
    func resetView()
    func handleFailedToAuthenticate(error: Error)
}

extension CanAuthenticateWithForm {
    
    func resetView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.emailTF.badInputIndicator.isHidden = true
            self.formRulesTextView.text = self.formRulesText
            self.formRulesTextView.textColor = UIColor(named: "decoration")
        }
    }
    
    func handleFailedToAuthenticate(error: Error) {
        formRulesTextView.text = error.localizedDescription
        formRulesTextView.textColor = UIColor(named: "text")
        if error.localizedDescription.first != "N" {
            emailTF.badInputIndicator.isHidden = false
        }
        resetView()
    }
    
}
