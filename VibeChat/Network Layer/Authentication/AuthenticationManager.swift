//
//  Authentication.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthenticationManager {
    
    // MARK:- Singleton Setup
    
    static let shared = AuthenticationManager()
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Public Methods
    
    public func createAccount(name: String, email: String, password: String, completion: @escaping (User?)->()) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            }
            guard let uid = result?.user.uid else {return}
            UsersManager.shared.uploadUserData(uid: uid, name: name, email: email) { (user) in
                completion(user)
            }
        }
    }
    
    public func logIn(email: String, password: String, completion: @escaping (User?)->()) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                completion(nil)
            }
            if let uid = result?.user.uid {
                UsersManager.shared.fetchUserData(uid: uid) { (user) in
                    user?.isOnline = true
                    completion(user)
                }
            }
        }
    }
    
    public func logOut(completion: @escaping ()->()) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error logging out user: \(error.localizedDescription)")
        }
        completion()
    }
    
    public func checkForValidUser(completion: @escaping (_ user: User?)->()) {
        if let uid = Auth.auth().currentUser?.uid {
            UsersManager.shared.fetchUserData(uid: uid) { (user) in
                if let user = user {
                    user.isOnline = true
                    DispatchQueue.main.async {
                        completion(user)
                    }
                }
            }
        } else {
            completion(nil)
        }
    }
    
    
}
