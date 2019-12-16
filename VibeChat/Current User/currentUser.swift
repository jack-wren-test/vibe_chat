//
//  currentUser.swift
//  VibeChat
//
//  Created by Jack Smith on 16/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation

// THERE'S PROBLEMS WITH THIS PATTERN, WE WANT TO USE DID SET TO REACT TO STUFF RIGHT? MAYBE NOT?

class currentUser {
    
    // MARK:- Singleton Setup
    
    static var shared = currentUser()
    public var user: User?
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    public func setNewUser(_ newUser: User) {
        user = newUser
    }
    
}
