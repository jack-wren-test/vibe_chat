//
//  ConversationsManager.swift
//  VibeChat
//
//  Created by Jack Smith on 18/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Firebase

/// Class for managing queries to Firestore userMessages location.
final class UserMessagesManager {
    
    // MARK:- Properties
    
    static let shared = UserMessagesManager()
    
    private let collectionReference = FirestoreManager.db.collection(dbCollection.userMessages.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods

    /// Create a conversation in the Firestore database for both users.
    /// - Parameters:
    ///   - conversation: The Conversation object to populate from
    ///   - completion: Completion handler passing an optional Conversation object
    public func createConversation(conversation: Conversation, completion: @escaping (_ success: Bool)->Void) {
        let group = DispatchGroup()
        group.enter()
        self.publishConversation(conversation.userUids[0],
                                 conversation.uid, conversation.toDict()) { success in
            if !success {
                completion(false)
                return
            }
            group.leave()
        }
        group.enter()
        self.publishConversation(conversation.userUids[1],
                                 conversation.uid, conversation.toDict()) { success in
            if !success {
                completion(false)
                return
            }
            group.leave()
        }
        group.notify(queue: .main) {
            completion(true)
        }
    }
    
    /// Publish a conversation in the database.
    /// - Parameters:
    ///   - forUserId: The user UID to publish under
    ///   - withConversationId: The conversation UID
    ///   - data: The data to publish
    ///   - completion: Completion handler passing a success truth value
    private func publishConversation(_ forUserId: String,
                                         _ withConversationId: String,
                                         _ data: [String : Any],
                                         _ completion: @escaping (_ success: Bool) -> Void) {
        self.collectionReference.document(forUserId)
        .collection(dbCollection.conversations.rawValue)
        .document(withConversationId).setData(data) { error in
            if let error = error {
                print("Error creating message thread: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Creates a listener for a specific converstion, returning the new conversation data when updates are made.
    /// - Parameters:
    ///   - conversaion: The Conversation object to listen to
    ///   - completion: Completion handler passing an optional Conversation object
    public func listenForConversationChanges(conversaion: Conversation,
                                             completion: @escaping (Conversation?)->Void) -> ListenerRegistration {
        let uid = CurrentUser.shared.data!.uid
        let conversationId = conversaion.uid
        let listener = self.collectionReference.document(uid)
            .collection(dbCollection.conversations.rawValue)
            .document(conversationId).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error adding listener to thread: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let snapshotData = snapshot?.data() else {return}
            let conversation = Conversation(withDictionary: snapshotData)
            completion(conversation)
        }
        return listener
    }
    
    /// Creates a listener for a user's conversation list, returning the new conversation data when updates are made.
    /// - Parameters:
    ///   - forUser: The User to listen to
    ///   - completion: Completion handler passing an array of Conversation objects (can be empty upon first call)
    public func listenToConversations(forUser: User,
                                      completion: @escaping ([Conversation])->Void) -> ListenerRegistration {
        let listener = self.collectionReference.document(forUser.uid)
            .collection(dbCollection.conversations.rawValue)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else {return}
                if let error = error {
                    print("Error adding new conversation listener: \(error.localizedDescription)")
                    return
                }
                guard let changes = snapshot?.documentChanges else {return}
                self.firestoreChangesToConversations(changes, completion: completion)
        }
        return listener
    }
    
    /// Parse Firestore database doucment changes to an array of Conversation objects.
    /// - Parameters:
    ///   - changes: The changes that have occured
    ///   - completion: Completion handler passing an array of Conversation objects
    fileprivate func firestoreChangesToConversations(_ changes: [DocumentChange],
                                                          completion: @escaping ([Conversation])->Void) {
        var conversations: [Conversation] = []
        let group = DispatchGroup()
        for change in changes {
            group.enter()
            let document = change.document
            let conversation = Conversation(withDictionary: document.data())
            conversation.fetchChatter { (success) in
                if success { conversations.append(conversation) }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(conversations)
        }
    }
    
    fileprivate func updateConversationStatusForUserUid(_ uid: String,
                                                        _ conversation: Conversation,
                                                        _ data: [String : Any],
                                                        _ group: DispatchGroup?) {
        group?.enter()
        collectionReference.document(uid)
            .collection(dbCollection.conversations.rawValue)
            .document(conversation.uid)
            .setData(data, merge: true) { (error) in
                if let error = error {
                    print("Error uploading message: \(error.localizedDescription)")
                    return
                }
                group?.leave()
        }
    }
    
    /// Updates the conversation status for both chatters in Firestore database
    /// - Parameters:
    ///   - conversation: The Conversation to update
    ///   - userIsRead: If the current user has read the conversation
    ///   - chatterIsRead: If the chatter has read the conversation
    ///   - withNewMessageTime: The time of the latest message
    ///   - completion: Completion handler passing nothing
    public func updateConversationStatus(conversation: Conversation,
                                         userIsRead: Bool,
                                         chatterIsRead: Bool,
                                         withNewMessageTime: Date?,
                                         completion: @escaping ()->Void) {
        guard let userUid = CurrentUser.shared.data?.uid else {return}
        let chatterUid = userUid == conversation.userUids[0] ? conversation.userUids[1] : conversation.userUids[0]

        var data: [String: Any] = ["isReadStatus": userIsRead]
        if let lastMessageTime = withNewMessageTime {
            data["lastMessageTime"] = Timestamp(date: lastMessageTime)
        }

        let group = DispatchGroup()
        self.updateConversationStatusForUserUid(userUid, conversation, data, group)
        data["isReadStatus"] = chatterIsRead
        self.updateConversationStatusForUserUid(chatterUid, conversation, data, group)
        group.notify(queue: .main) {
            completion()
        }
    }
    
    /// Updates a conversation status (is read, time of last message) for the current user.
    /// - Parameters:
    ///   - conversation: The conversation to update
    ///   - toIsRead: The conversation's is read value
    ///   - withNewMessageTime: The conversation's last message time value
    public func updateConversationStatusForCurrentUser(conversation: Conversation, toIsRead: Bool, withNewMessageTime: Date?) {
        var data: [String: Any] = ["isReadStatus": toIsRead]
        if let lastMessageTime = withNewMessageTime {
            data["lastMessageTime"] = Timestamp(date: lastMessageTime)
        }
        guard let uid = CurrentUser.shared.data?.uid else {return}
        self.updateConversationStatusForUserUid(uid, conversation, data, nil)
    }
}
