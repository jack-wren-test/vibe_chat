//
//  MessagesClient.swift
//  VibeChat
//
//  Created by Jack Smith on 10/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import FirebaseFirestore

final class MessagesManager: FirestoreManager {
    
    // MARK:- Singleton Setup
    
    static let shared = MessagesManager()
    private let collectionReference = FirestoreManager.db.collection(dbCollection.messaging.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    public func uploadMessage(message: Message) {
        guard let uid = CurrentUser.shared.user?.uid else {return}
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(message.threadId).collection(dbCollection.messages.rawValue).addDocument(data: message.toDict()) { (error) in
            if let error = error {
                print("Error uploading message: \(error.localizedDescription)")
                return
            }
            self.updateConversationStatus(threadUid: message.threadId, lastMessageTime: Date(), isReadStatus: false)
        }
    }
    
    public func listenForMessages(onThread: String, completion: @escaping ([Message]?)->()) {
       guard let uid = CurrentUser.shared.user?.uid else {return}
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(onThread).collection(dbCollection.messages.rawValue).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error retrieving snapshot: \(error.localizedDescription)")
                completion(nil)
            }
            if let snapshot = snapshot?.documentChanges {
                self.snapshotDocumentsToMessageArray(snapshot, completion: completion)
            }
        }
    }
    
    public func listenForConversationChanges(onThread: String, completion: @escaping (Conversation?)->()) {
        guard let uid = CurrentUser.shared.user?.uid else {return}
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(onThread).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error adding listener to thread: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let snapshotData = snapshot?.data() {
                let thread = Conversation(withDictionary: snapshotData)
                completion(thread)
            }
        }
    }
    
    public func listenToConversationsForCurrentUser(completion: @escaping ([Conversation]?)->()) {
        guard let uid = CurrentUser.shared.user?.uid else {return}
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error adding listener to user conversations: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let documentChanges = snapshot?.documentChanges {
                var conversations = [Conversation]()
                for documentChange in documentChanges {
                    conversations.append(Conversation(withDictionary: documentChange.document.data()))
                }
                completion(conversations)
            }
        }
    }
    
    public func updateConversationStatus(threadUid: String, lastMessageTime: Date?, isReadStatus: Bool) {
        guard let uid = CurrentUser.shared.user?.uid else {return}
        var data: [String: Any] = ["isReadStatus": isReadStatus]
        if let lastMessageTime = lastMessageTime {
            data["lastMessageTime"] = Timestamp(date: lastMessageTime)
        }
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).document(threadUid).setData(data, merge: true)
    }
    
    public func createMessageThreadIfNeeded(chatterUid: String, completion: @escaping (_ threadId: String?)->()) {
        guard let uid = CurrentUser.shared.user?.uid else {return}
        var foundMatch: Bool = false
        let potentialThreadIds = [uid+"_"+chatterUid, chatterUid+"_"+uid]
        collectionReference.document(uid).collection(dbCollection.conversations.rawValue).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking for message threads: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let threadIds = snapshot?.documents else {completion(nil); return}
            threadIds.forEach { (threadId) in
                potentialThreadIds.forEach { (potentialThreadId) in
                    if threadId.documentID == potentialThreadId && foundMatch == false {
                        completion(threadId.documentID)
                        foundMatch = !foundMatch
                    }
                }
            }
            if !foundMatch {
                self.createMessageThread(withThreadId: potentialThreadIds[0]) { (threadId) in
                    if let threadId = threadId {
                        print("Created new thread: \(threadId)")
                        completion(threadId)
                    }
                }
            }
        }
    }
    
    fileprivate func createMessageThread(withThreadId: String, completion: @escaping (_ threadId: String?)->()) {
        let seperatedText = withThreadId.split(separator: "_")
        let firstId = String(seperatedText.first!)
        let secondId = String(seperatedText.last!)
        let data: [String: Any] = ["userUids": [firstId, secondId],
                                   "type": "private",
                                   "isReadStatus": true,
                                   "lastMessageTime": Timestamp(date: Date()),
                                   "threadUid": withThreadId]
        collectionReference.document(firstId).collection(dbCollection.conversations.rawValue).document(withThreadId).setData(data) { (error) in
            if let error = error {
                print("Error creating message thread: \(error.localizedDescription)")
                completion(nil)
                return
            }
        }
        collectionReference.document(secondId).collection(dbCollection.conversations.rawValue).document(withThreadId).setData(data) { (error) in
            if let error = error {
                print("Error creating message thread: \(error.localizedDescription)")
                completion(nil)
                return
            }
        }
        
    }
    
    // CHANGE THIS TO GENERIC DATA ARRAY FOR USE WITH USERS TOO? THEN COULD PUT IN DATABASEMANAGERCLASS
    fileprivate func snapshotDocumentsToMessageArray(_ documentChange: [DocumentChange], completion: @escaping ([Message]?)->()) {
        var messages = [Message]()
        documentChange.forEach { (document) in
            let messageData = document.document.data()
            let message = Message(withDictionary: messageData)
            messages.append(message)
        }
        DispatchQueue.main.async {
            completion(messages)
        }
    }
    
}
