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
    public var data: User?
    
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
        data?.isOnline = true
        data = newUser
    }
    
    public func nullifyUser() {
        data?.isOnline = false
        data = nil
    }
    
    public func updateUserDataInDb(completion: @escaping ()->()) {
        guard let data = data else {return}
        UsersManager.shared.updateUserData(toUserUid: data.uid, withData: data.toDict()) {
            completion()
        }
    }
    
}
