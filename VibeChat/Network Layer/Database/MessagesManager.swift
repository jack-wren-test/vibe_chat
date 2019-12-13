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
    private let collectionReference = FirestoreManager.db.collection(dbCollection.messageThreads.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    public func uploadMessage(message: Message, completion: @escaping (_ success: Bool)->()) {
        collectionReference.document(message.threadId).collection(dbCollection.messages.rawValue).addDocument(data: message.toDict()) { (error) in
            if let error = error {
                print("Error uploading message: \(error.localizedDescription)")
                completion(false)
            }
            completion(true)
        }
    }
    
    public func listenForMessages(onThread: String, completion: @escaping ([Message]?)->()) {
        collectionReference.document(onThread).collection(dbCollection.messages.rawValue).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error retrieving snapshot: \(error.localizedDescription)")
                completion(nil)
            }
            if let snapshot = snapshot?.documentChanges {
                self.snapshotDocumentsToMessageArray(snapshot, completion: completion)
            }
        }
    }
    
    public func createMessageThreadIfNeeded(userUid: String, chatterUid: String, completion: @escaping (_ threadId: String?)->()) {
        var foundMatch: Bool = false
        let potentialThreadIds = [userUid+"_"+chatterUid, chatterUid+"_"+userUid]
        collectionReference.getDocuments { (snapshot, error) in
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
        let firstId = seperatedText.first
        let secondId = seperatedText.last
        let data: [String: Any] = ["userUids": [firstId, secondId],
                                   "type": "private"]
        collectionReference.document(withThreadId).setData(data) { (error) in
            if let error = error {
                print("Error creating message thread: \(error.localizedDescription)")
                completion(nil)
                return
            } else {
                completion(withThreadId)
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
