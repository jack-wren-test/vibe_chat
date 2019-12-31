//
//  MessageThread.swift
//  VibeChat
//
//  Created by Jack Smith on 17/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

// INCORPORATE MODEL

enum MessageThreadType: String {
    typealias RawValue = String
    case Private, Group
}

class Conversation {
    
    // MARK:- Properties
    
    var hasDbCounterpart:   Bool = false
    var type:               String
    var lastMessageTime:    Date
    var uid:                String
    var userUids:           [String]
    var userNames:          [String]
    var chatter:            User?
    var isReadStatus:       Bool {
        didSet {
            if hasDbCounterpart {
                UserMessagesManager.shared.updateConversationStatusForCurrentUser(conversation: self,
                                                                                  toIsRead: isReadStatus,
                                                                                  withNewMessageTime: lastMessageTime)
            }
        }
    }
    
    // MARK:- Init
    
    init(withChatter: User) {
        type = "private"
        lastMessageTime = Date()
        uid = CurrentUser.shared.data!.uid+"_"+withChatter.uid
        userUids = [CurrentUser.shared.data!.uid, withChatter.uid]
        userNames = [CurrentUser.shared.data!.name, withChatter.name]
        chatter = withChatter
        isReadStatus = false
    }
    
    init(withDictionary: [String: Any]) {
        type = withDictionary["type"] as! String
        isReadStatus = withDictionary["isReadStatus"] as! Bool
        lastMessageTime = (withDictionary["lastMessageTime"] as! Timestamp).dateValue()
        userUids = withDictionary["userUids"] as! [String]
        userNames = withDictionary["userNames"] as! [String]
        uid = withDictionary["uid"] as! String
        hasDbCounterpart = true
        fetchChatter()
    }
    
    // MARK:- Methods
    
    public func toDict() -> [String: Any] {
        let data: [String: Any] = ["userNames": [CurrentUser.shared.data?.name, chatter?.name],
                                   "userUids": [CurrentUser.shared.data?.uid, chatter?.uid],
                                   "type": "private",
                                   "isReadStatus": false,
                                   "lastMessageTime": Timestamp(date: Date()),
                                   "uid": uid]
        return data
    }
    
    public func fetchChatter(completion: @escaping ()->() = {}) {
        let chatterUid = CurrentUser.shared.data?.uid == userUids[0] ? userUids[1] : userUids[0]
        UsersManager.shared.fetchUserData(uid: chatterUid) { (user) in
            if let user = user {
                UsersManager.shared.listenToUserData(user: user) { (user) in
                    self.chatter = user
                    completion()
                }
            }
        }
    }
    
}
