//
//  MessagesClient.swift
//  VibeChat
//
//  Created by Jack Smith on 10/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import FirebaseFirestore

/// Class for managing queries to Firestore messages location.
final class MessagingManager: FirestoreManager {
    
    // MARK:- Properties
    
    static let shared = MessagingManager()
    
    private let collectionReference = FirestoreManager.db.collection(dbCollection.messaging.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    /// Upload a message to Firestore database.
    /// - Parameters:
    ///   - message: The message to be uploaded
    ///   - completion: Completion handler passing a success truth value
    public func uploadMessage(message: Message, completion: @escaping ((_ success: Bool)->Void) = {_ in}) {
        guard let conversationId = message.conversationId else {return}
        self.collectionReference.document(conversationId)
            .collection(dbCollection.messages.rawValue)
            .addDocument(data: message.dictionaryRepresentation) { error in
            if let error = error {
                print("Error uploading message: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Creates a listener for listening for new messages in a specified conversation.
    /// - Parameters:
    ///   - onConversation: The conversation to listen to
    ///   - completion: Completion handler passing optional array of Message objects
    /// - Returns:
    ///   - The listener registration object
    public func listenForMessages(onConversation: Conversation, completion: @escaping ([Message]?)->Void) -> ListenerRegistration {
        let conversationId = onConversation.uid
        let messageQueryRef = self.collectionReference.document(conversationId)
            .collection(dbCollection.messages.rawValue).order(by: "timestamp", descending: true).limit(to: 25)
        let listener = messageQueryRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error retrieving snapshot: \(error.localizedDescription)")
                completion(nil)
            }
            guard let snapshot = snapshot?.documentChanges else {return}
            var messages = self.firestoreDocumentsToMessageArray(snapshot)
            
            if messages?.count == 2 { // HACKY FIX
                messages?.remove(at: 0)
            }
            
            DispatchQueue.main.async {
                completion(messages)
            }
        }
        return listener
    }
    
    public func fetchMessages(firstMessage: Message?, onConversation: Conversation, completion: @escaping ([Message]?)->Void) {
        guard let firstMessageDate = firstMessage?.timestamp else {return}
        let firstPostTimestamp = Timestamp(date: firstMessageDate)
        let conversationId = onConversation.uid
        let messageQueryRef = self.collectionReference.document(conversationId)
            .collection(dbCollection.messages.rawValue).order(by: "timestamp", descending: true).start(after: [firstPostTimestamp]).limit(to: 25)
        messageQueryRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error retrieving snapshot: \(error.localizedDescription)")
                completion(nil)
            }
            guard let snapshot = snapshot?.documentChanges else {return}
            let messages = self.firestoreDocumentsToMessageArray(snapshot)
            DispatchQueue.main.async {
                completion(messages)
            }
        }
    }
    
    /// Parses an array of Firebase DocumentChange objects to array of Message objects.
    /// - Parameters:
    ///   - documentChange: The document change to parse
    ///   - completion: Completion handler passing array of optional Message objects
    private func firestoreDocumentsToMessageArray(_ documentChange: [DocumentChange]) -> [Message]? {
        var messages = [Message]()
        documentChange.forEach { document in
            let messageData = document.document.data()
            if messageData["videoUrl"] != nil {
                let videoMessage = VideoMessage(withDictionary: messageData)
                messages.append(videoMessage)
            } else if messageData["imageUrl"] != nil {
                let imageMessage = ImageMessage(withDictionary: messageData)
                messages.append(imageMessage)
            } else if messageData["giphId"] != nil {
                let giphyMessage = GiphyMessage(withDictionary: messageData)
                messages.append(giphyMessage)
            } else {
                let message = TextMessage(withDictionary: messageData)
                messages.append(message)
            }
        }
        return messages
    }
    
}
