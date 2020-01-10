//
//  ConversationsManager.swift
//  VibeChat
//
//  Created by Jack Smith on 18/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Firebase


/// <#Description#>
final class UserMessagesManager {
    
    // MARK:- Properties
    
    static let shared = UserMessagesManager()
    
    private let collectionReference = FirestoreManager.db.collection(dbCollection.userMessages.rawValue)
    
    // MARK:- Private Init (Force Singleton)
    
    private func Init() {}
    
    // MARK:- Methods
    
    fileprivate func checkForExistingConversation(_ conversation: Conversation,
                                                  _ userConversations: [QueryDocumentSnapshot],
                                                  completion: @escaping (_ conversation: Conversation?)->Void) {
        guard let uid = CurrentUser.shared.data?.uid else {return}
        guard let chatter = conversation.chatter else {return}
        var foundMatch: Bool = false
        let potentialConversationIds = [uid+"_"+chatter.uid, chatter.uid+"_"+uid]
        for conversation in userConversations {
            for potentialConversationId in potentialConversationIds {
                if conversation.documentID == potentialConversationId && foundMatch == false {
                    completion(nil)
                    foundMatch = !foundMatch
                }
            }
        }
        if !foundMatch {
            self.createConversation(conversation: conversation, andChatterName: chatter.uid, completion: completion)
        }
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - conversation: <#conversation description#>
    ///   - completion: <#completion description#>
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
    
    fileprivate func createConversation(conversation: Conversation, andChatterName: String, completion: @escaping (_ conversation: Conversation?)->()) {
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
    
    public func listenToConversations(forUser: User, completion: @escaping ([Conversation])->()) -> ListenerRegistration {
        let listener = collectionReference.document(forUser.uid).collection(dbCollection.conversations.rawValue).addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error adding new conversation listener: \(error.localizedDescription)")
                return
            }
            var conversations: [Conversation] = []
            let group = DispatchGroup()
            if let changes = snapshot?.documentChanges {
                group.enter()
                for change in changes {
                    group.enter()
                    let document = change.document
                    let conversation = Conversation(withDictionary: document.data())
                    conversation.fetchChatter { (success) in
                        if success { conversations.append(conversation) }
                        group.leave()
                    }
                }
            }
            group.leave()
            group.notify(queue: .main) {
                completion(conversations)
            }
        }
        return listener
    }
    
    public func fetchConversationList(forUser: User, completion: @escaping ([Conversation]?)->()) {
        collectionReference.document(forUser.uid).collection(dbCollection.conversations.rawValue).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user conversations: \(error.localizedDescription)")
                completion(nil)
                return
            }
            let group = DispatchGroup()
            if let documents = snapshot?.documents {
                group.enter()
                var conversations = [Conversation]()
                for document in documents {
                    group.enter()
                    let data = document.data()
                    let conversation = Conversation(withDictionary: data)
                    conversation.fetchChatter { (success) in
                        if success {conversations.append(conversation)}
                        group.leave()
                    }
                }
                group.leave()
                group.notify(queue: .main) {
                    completion(conversations)
                }
            }
        }
    }
    
    public func updateConversationStatus(conversation: Conversation, userIsRead: Bool, chatterIsRead: Bool, withNewMessageTime: Date?, completion: @escaping ()->()) {
//        print("Update conversation status called")
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
    
    public func updateConversationStatusForChatter(conversation: Conversation, toIsRead: Bool, withNewMessageTime: Date?) {
//        print("Update conversation status for chatter called...")
        guard let uid = CurrentUser.shared.data?.uid else {return}
        let chatterUid = uid == conversation.userUids[0] ? conversation.userUids[1] : conversation.userUids[0]
        updateConversationStatus(conversation, toIsRead, withNewMessageTime, chatterUid)
    }

    public func updateConversationStatusForCurrentUser(conversation: Conversation, toIsRead: Bool, withNewMessageTime: Date?) {
//        print("Update conversation status for current user called...")
        guard let uid = CurrentUser.shared.data?.uid else {return}
        updateConversationStatus(conversation, toIsRead, withNewMessageTime, uid)
    }

    fileprivate func updateConversationStatus(_ conversation: Conversation, _ toIsRead: Bool, _ withNewMessageTime: Date?, _ forUid: String) {
//        print("Update conversation status 2 called...")
        var data: [String: Any] = ["isReadStatus": toIsRead]
        if let lastMessageTime = withNewMessageTime {
            data["lastMessageTime"] = Timestamp(date: lastMessageTime)
        }
        collectionReference.document(forUid).collection(dbCollection.conversations.rawValue).document(conversation.uid).setData(data, merge: true)
    }
    
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
    
    
}
