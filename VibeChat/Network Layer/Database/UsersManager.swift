//
//  UsersManager.swift
//  VibeChat
//
//  Created by Jack Smith on 10/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import FirebaseFirestore

enum userField: String {
    typealias RawValue = String
    case name, email, uid, vibe, status, isOnline, profileImageUrl
}

final class UsersManager: FirestoreManager {
    
    // MARK:- Singleton Setup
    
    static let shared = UsersManager()
    private let collectionReference = FirestoreManager.db.collection(dbCollection.users.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    // REFACTOR TO TAKE IN USERS RATHER THAN DATA AS TO ADHERE TO DEPENDENCY INJECTION

    public func fetchChatters(completion: @escaping ([User]?)->()) {
        collectionReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                completion(nil)
            }
            if let snapshotArray = snapshot?.documents {
                var users = [User]()
                snapshotArray.forEach { (snapshot) in
                    let userData = snapshot.data()
                    let uid = userData["uid"] as! String
                    if uid != CurrentUser.shared.data?.uid {
                        let user = User(withDictionary: userData)
                        users.append(user)
                    }
                }
                DispatchQueue.main.async {
                    completion(users)
                }
            }
        }
    }
    
    public func updateUserData(toUserUid: String, withData: [String: Any], completion: @escaping ()->()) {
        collectionReference.document(toUserUid).setData(withData) { (error) in
            if let error = error {
                print("Error updating values: \(error)")
                completion()
            }
            completion()
        }
    }
    
    public func uploadUserData(uid: String, name: String, email: String, completion: @escaping (User?)->()) {
        let data : [String: Any] = ["name" : name,
                                    "uid" : uid,
                                    "email" : email,
                                    "status": "I just joined the vibe ~~~",
                                    "vibe": "Free for All Friday 🥳"]
        FirestoreManager.db.collection("users").document(uid).setData(data) { (error) in
            if let error = error {
                print("Error uploading new user data: \(error.localizedDescription)")
                completion(nil)
            } else {
                self.fetchUserData(uid: uid) { (user) in
                    completion(user)
                }
            }
        }
    }
    
    public func toggleIsOnline(user: User) {
        collectionReference.document(user.uid).updateData([userField.isOnline.rawValue: user.isOnline]) { (error) in
            if let error = error {
                print("Error updating online status: \(error.localizedDescription)")
            }
        }
    }
    
    public func fetchUserData(uid: String, completion: @escaping (User?)->()) {
        collectionReference.document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
            }
            if let userData = snapshot?.data() {
                let user = User(withDictionary: userData)
                completion(user)
            }
        }
    }
    
    public func listenToUserData(user: User, completion: @escaping (User?)->()) {
        collectionReference.document(user.uid).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
            }
            if let userData = snapshot?.data() {
                let user = User(withDictionary: userData)
                completion(user)
            }
        }
    }
    
}
