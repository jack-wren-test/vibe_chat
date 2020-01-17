//
//  MessageThread.swift
//  VibeChat
//
//  Created by Jack Smith on 17/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

/// Enummeration for conversation types.
enum ConversationType: String {
    typealias RawValue = String
    case Private, Group
}

/// Model for a conversation between two or more users.
class Conversation {
    
    // MARK:- Properties
    
    private(set) var hasDbCounterpart:   Bool = false
    private(set) var type:               String
    private(set) var lastMessageTime:    Date
    private(set) var uid:                String
    private(set) var userUids:           [String]
    private(set) var userNames:          [String]
    private(set) var chatter:            User?
    private(set) var chatterListener:    ListenerRegistration?
    var isReadStatus:       Bool {
        didSet {
            if hasDbCounterpart {
                UserMessagesManager.shared.updateConversationStatusForCurrentUser(conversation: self,
                                                                                  toIsRead: isReadStatus,
                                                                                  withNewMessageTime: lastMessageTime)
            }
        }
    }
    
    // MARK:- Lifecycle
    
    /// Init for mocking a basic conversation (for use only in testing).
    /// - Parameter uid: The unique identifier to give the conversation
    init(uid: String) {
        self.uid = uid
        self.type = "private"
        self.lastMessageTime = Date()
        self.userNames = ["Test1","Test2"]
        self.userUids = [uid, NSUUID().uuidString]
        self.isReadStatus = true
    }
    
    /// Init from chatter details. For use when a conversation is created with the application.
    /// - Parameter withChatter: The chatter to create a conversation with
    init(withChatter: User) {
        self.type = "private"
        self.lastMessageTime = Date()
        self.chatter = withChatter
        self.isReadStatus = false
        
        if let userData = CurrentUser.shared.data {
            self.uid = Conversation.generateConversationUid(user: userData, chatter: withChatter)
            self.userUids = [userData.uid, withChatter.uid]
            self.userNames = [userData.name, withChatter.name]
        } else { // Hack for testing
            let dummyData = User(uid: "dummyCurrentUser", name: "Dummy Test", email: "dummy@test.com")
            self.uid = Conversation.generateConversationUid(user: dummyData, chatter: withChatter)
            self.userUids = [dummyData.uid, withChatter.uid]
            self.userNames = [dummyData.name, withChatter.name]
        }
        
    }
    
    /// Init from [String: Any] Dictionary. For use when creating a conversation from Firestore data.
    /// - Parameter withDictionary: The dictionary to create a conversation from
    init(withDictionary: [String: Any]) {
        self.type = withDictionary["type"] as! String
        self.isReadStatus = withDictionary["isReadStatus"] as! Bool
        self.lastMessageTime = (withDictionary["lastMessageTime"] as! Timestamp).dateValue()
        self.userUids = withDictionary["userUids"] as! [String]
        self.userNames = withDictionary["userNames"] as! [String]
        self.uid = withDictionary["uid"] as! String
        self.hasDbCounterpart = true
    }
    
    deinit {
        self.chatterListener?.remove()
    }
    
    // MARK:- Methods
    
    /// Returns a Dictionary representation of the Conversation
    public func toDict() -> [String: Any] {
        let data: [String: Any] = ["userNames": [CurrentUser.shared.data?.name, chatter?.name],
                                   "userUids": [CurrentUser.shared.data?.uid, chatter?.uid],
                                   "type": "private",
                                   "isReadStatus": false,
                                   "lastMessageTime": Timestamp(date: Date()),
                                   "uid": uid]
        return data
    }
    
    /// Fetches the chatter associated with the conversation.
    /// - Parameter completion: Completion handler passing a success truth value
    public func fetchChatter(completion: @escaping (_ success: Bool)->()) {
        let chatterUid = CurrentUser.shared.data?.uid == userUids[0] ? userUids[1] : userUids[0]
        UsersManager.shared.fetchUserData(uid: chatterUid) { [weak self] user in
            guard let self = self else {return}
            if let user = user {
                self.chatter = user
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Creates a listener to listen to changes for the chatter associated with the conversation.
    /// - Parameter completion: Completion handler with a default empty implementation
    public func listenToChatter(completion: @escaping ()->Void = {}) {
        if let chatter = chatter {
            self.chatterListener = UsersManager.shared.listenToUserData(user: chatter) { [weak self] user in
                guard let self = self else {return}
                self.chatter = user
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    static func generateConversationUid(user: User, chatter: User) -> String {
        var uid: String
        let userUid = user.uid, chatterUid = chatter.uid
        if userUid < chatterUid {
            uid = userUid+"_"+chatterUid
        } else {
            uid = chatterUid+"_"+userUid
        }
        return uid
    }
    
}
