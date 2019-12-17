//
//  currentUser.swift
//  VibeChat
//
//  Created by Jack Smith on 16/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation

// THINK ABOUT HOW WE CAN BETTER USE ENCAPSULATION HERE AND IN THE USER CLASS

final class CurrentUser {
    
    // MARK:- Singleton Setup
    
    static var shared = CurrentUser()
    public var user: User?
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    public func logIn(withEmail: String, andPassword: String, completion: @escaping ()->()) {
        AuthenticationManager.shared.logIn(email: withEmail, password: andPassword) { (user) in
            if let user = user {
                self.setNewUser(user)
                completion()
            }
        }
    }
    
    public func logOut() {
        AuthenticationManager.shared.logOut {
            self.nullifyUser()
        }
    }
    
    public func setNewUser(_ newUser: User) {
        user?.isOnline = true
        user = newUser
    }
    
    public func nullifyUser() {
        user?.isOnline = false
        user = nil
    }
    
    public func updateUserDataInDb(completion: @escaping ()->()) {
        guard let user = user else {return}
        UsersManager.shared.updateUserData(toUserUid: user.uid, withData: user.toDict()) {
            completion()
        }
    }
    
}
