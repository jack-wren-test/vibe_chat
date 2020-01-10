//
//  UsersManager.swift
//  VibeChat
//
//  Created by Jack Smith on 10/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import FirebaseFirestore

/// Class for managing queries to Firestore users location.
final class UsersManager: FirestoreManager {
    
    // MARK:- Properties
    
    static let shared = UsersManager()
    
    private let collectionReference = FirestoreManager.db.collection(dbCollection.users.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    /// Fetch all chatters from Firestore database.
    /// - Parameter completion: Completion handler passing an optional array of User objects
    public func fetchChatters(completion: @escaping ([User]?)->()) {
        collectionReference.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                completion(nil)
            }
            guard let snapshotArray = snapshot?.documents else {return}
            self.firestoreDocumentsToUsers(snapshotArray, completion: completion)
        }
    }
    
    /// Parse Firestore documents to Users.
    /// - Parameters:
    ///   - snapshotArray: Firestore documents to parse
    ///   - completion: Completion handler passing an optional array of User objects
    fileprivate func firestoreDocumentsToUsers(_ snapshotArray: [QueryDocumentSnapshot],
                                               completion: @escaping ([User]?)->Void) {
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
    
    /// Update user data in Firestore database.
    /// - Parameters:
    ///   - forUser: The user to update
    ///   - completion: Completion handler passing success truth value
    public func updateUserData(forUser: User, completion: @escaping (Bool)->Void) {
        collectionReference.document(forUser.uid).setData(forUser.toDict()) { (error) in
            if let error = error {
                print("Error uploading new user data: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Toggle the current user's isOnline status.
    /// - Parameter user: The user to update
    public func toggleIsOnline(user: User) {
        collectionReference.document(user.uid).updateData(["isOnline": user.isOnline]) { (error) in
            if let error = error {
                print("Error updating online status: \(error.localizedDescription)")
            }
        }
    }
    
    /// Fetch user data.
    /// - Parameters:
    ///   - uid: The uid to fetch user data for
    ///   - completion: Completion handler passing an optional User object
    public func fetchUserData(uid: String, completion: @escaping (User?)->Void) {
        collectionReference.document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let userData = snapshot?.data() {
                let user = User(withDictionary: userData)
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Create listener to listen to user data changes in the Firestore database.
    /// - Parameters:
    ///   - user: The user to listen to
    ///   - completion: Completion handler passing an optional User object
    public func listenToUserData(user: User, completion: @escaping (User?)->()) -> ListenerRegistration {
        let listener = collectionReference.document(user.uid).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil)
            }
            if let userData = snapshot?.data() {
                let user = User(withDictionary: userData)
                completion(user)
            }
        }
        return listener
    }
    
}
