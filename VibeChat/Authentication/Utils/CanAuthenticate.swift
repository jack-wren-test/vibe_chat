//
//  CanAuthenticate.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation

protocol CanAuthenticate {
    func checkPasswordIsComplex(password: String) -> Bool
    func isFormValid() -> Bool
    func performAuthentication()
    func addTextFieldDidChangeActions()
    func enableAuthenticateButtonIfNeeded()
    func presentHomeScreen(_ user: User)
}

extension CanAuthenticate {
    
    func checkPasswordIsComplex(password: String) -> Bool {
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
    
}
