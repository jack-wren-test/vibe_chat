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
    
    /// Check for existing conversation in the Firestore database and create a new one if nessesary.
    /// - Parameters:
    ///   - conversation: The conversation object to create data for in the database
    ///   - completion: Completion handler passing an optional Conversation object
    public func createConversationIfNeeded(conversation: Conversation, completion: @escaping (_ conversation: Conversation?)->()) {
        guard let uid = CurrentUser.shared.data?.uid else {return}
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking for message threads: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let userConversations = snapshot?.documents else {completion(nil); return}
            self.checkForExistingConversation(conversation, userConversations, completion: completion)
        }
    }
    
    /// Check a users conversation list for an existing conversation.
    /// - Parameters:
    ///   - conversation: The Onversation object to check for
    ///   - userConversations: The conversations for the current user in the database
    ///   - completion: Completion handler passing a Conversation object
    fileprivate func checkForExistingConversation(_ conversation: Conversation,
                                                  _ userConversations: [QueryDocumentSnapshot],
                                                  completion: @escaping (_ conversation: Conversation?)->Void) {
        guard let uid = CurrentUser.shared.data?.uid else {return}
        guard let chatter = conversation.chatter else {return}
        let potentialConversationIds = [uid+"_"+chatter.uid, chatter.uid+"_"+uid]
        for conversation in userConversations {
            for potentialConversationId in potentialConversationIds {
                if conversation.documentID == potentialConversationId {
                    completion(nil)
                    return
                }
            }
        }
        self.createConversation(conversation: conversation, completion: completion)
    }
    
    /// Create a conversation in the Firestore database for both users.
    /// - Parameters:
    ///   - conversation: The Conversation object to populate from
    ///   - completion: Completion handler passing an optional Conversation object
    fileprivate func createConversation(conversation: Conversation, completion: @escaping (_ conversation: Conversation?)->()) {
        let group = DispatchGroup()
        group.enter()
        publishConversation(conversation.userUids[0], conversation.uid, conversation.toDict()) { (success) in
            group.leave()
        }
        group.enter()
        publishConversation(conversation.userUids[1], conversation.uid, conversation.toDict()) { (success) in
            group.leave()
        }
        group.notify(queue: .main) {
            completion(conversation)
        }
    }
    
    /// Publish a conversation in the database.
    /// - Parameters:
    ///   - forUserId: The user UID to publish under
    ///   - withConversationId: The conversation UID
    ///   - data: The data to publish
    ///   - completion: Completion handler passing a success truth value
    fileprivate func publishConversation(_ forUserId: String, _ withConversationId: String, _ data: [String : Any], _ completion: @escaping (_ success: Bool) -> ()) {
    collectionReference.document(forUserId).collection(dbCollection.conversations.rawValue).document(withConversationId).setData(data) { (error) in
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
    public func listenForConversationChanges(conversaion: Conversation, completion: @escaping (Conversation?)->()) -> ListenerRegistration {
        let uid = CurrentUser.shared.data!.uid
        let conversationId = conversaion.uid
        let listener = collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(conversationId).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error adding listener to thread: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let snapshotData = snapshot?.data() {
                let conversation = Conversation(withDictionary: snapshotData)
                completion(conversation)
            }
        }
        return listener
    }
    
    /// Creates a listener for a user's conversation list, returning the new conversation data when updates are made.
    /// - Parameters:
    ///   - forUser: The User to listen to
    ///   - completion: Completion handler passing an array of Conversation objects (can be empty upon first call)
    public func listenToConversations(forUser: User, completion: @escaping ([Conversation])->()) -> ListenerRegistration {
        let listener = collectionReference.document(forUser.uid).collection(dbCollection.conversations.rawValue).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error adding new conversation listener: \(error.localizedDescription)")
                return
            }
            guard let changes = snapshot?.documentChanges else {return}
            self.firestoreChangesToConversations(changes, completion: completion)
        }
        return listener
    }
    
    /// Fetch the conversation list for a user.
    /// - Parameters:
    ///   - forUser: The user who's conversations to return
    ///   - completion: Completion handler passing an optional array of Conversation objects
    public func fetchConversationList(forUser: User, completion: @escaping ([Conversation]?)->Void) {
        collectionReference.document(forUser.uid).collection(dbCollection.conversations.rawValue).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user conversations: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let documents = snapshot?.documents else {return}
            self.firestoreDocumentsToConversations(documents, completion: completion)
        }
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
    
    // VVVV Very similar to aboce funtion, refactor
    
    /// Parse Firestore database documents to an array of Conversation objects.
    /// - Parameters:
    ///   - documents: The documents to parse
    ///   - completion: Completion handler passing an array of Conversation objects
    public func firestoreDocumentsToConversations(_ documents: [QueryDocumentSnapshot],
                                                            completion: @escaping ([Conversation]?)->Void) {
        var conversations = [Conversation]()
        let group = DispatchGroup()
        group.enter()
        for document in documents {
            group.enter()
            let data = document.data()
            let conversation = Conversation(withDictionary: data)
            conversation.fetchChatter { (success) in
                if success {conversations.append(conversation)}
                group.leave()
            }
            group.leave()
            group.notify(queue: .main) {
                completion(conversations)
            }
        }
    }
    
    /// Updates the conversation status for both chatters in Firestore database
    /// - Parameters:
    ///   - conversation: The Conversation to update
    ///   - userIsRead: If the current user has read the conversation
    ///   - chatterIsRead: If the chatter has read the conversation
    ///   - withNewMessageTime: The time of the latest message
    ///   - completion: Completion handler passing nothing
    public func updateConversationStatus(conversation: Conversation, userIsRead: Bool, chatterIsRead: Bool, withNewMessageTime: Date?, completion: @escaping ()->Void) {
        guard let uid = CurrentUser.shared.data?.uid else {return}
        let chatterUid = uid == conversation.userUids[0] ? conversation.userUids[1] : conversation.userUids[0]

        var data: [String: Any] = ["isReadStatus": userIsRead]
        if let lastMessageTime = withNewMessageTime {
            data["lastMessageTime"] = Timestamp(date: lastMessageTime)
        }

        let group = DispatchGroup()
        group.enter()
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(conversation.uid).setData(data, merge: true) { (error) in
            if let error = error {print("Error uploading message: \(error.localizedDescription)"); return}
            group.leave()
        }

        data["isReadStatus"] = chatterIsRead
        group.enter()
        collectionReference.document(chatterUid).collection(dbCollection.conversations.rawValue).document(conversation.uid).setData(data, merge: true) { (error) in
            if let error = error {print("Error uploading message: \(error.localizedDescription)"); return}
            group.leave()
        }
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
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(conversation.uid).setData(data, merge: true)
    }
    
    
}
