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
    
    var type:               String
    var lastMessageTime:    Date
    var uid:                String
    var userUids:           [String]
    var userNames:          [String]
    var chatter:            User? {
        didSet {
//            guard let chatter = chatter else {return}
//            print("Chatter: \(chatter.name) is online: \(chatter.isOnline)")
//            chatterIsOnline = chatter.isOnline
        }
    }
    var chatterIsOnline:    Bool? {
        didSet {
//            print("Chatter is online did set called...")
//            UserMessagesManager.shared.toggleChatterIsOnline(conversation: self)
        }
    }
    var isReadStatus:       Bool {
        didSet {
//            print("isRead status did set called...")
//            UserMessagesManager.shared.updateConversationStatusForCurrentUser(conversation: self,
//                                                                              toIsRead: isReadStatus,
//                                                                              withNewMessageTime: lastMessageTime)
        }
    }
    
    // MARK:- Init
    
    init(withChatter: User) {
        type = "private"
        lastMessageTime = Date()
        uid = CurrentUser.shared.user!.uid+"_"+withChatter.uid
        userUids = [CurrentUser.shared.user!.uid, withChatter.uid]
        userNames = [CurrentUser.shared.user!.name, withChatter.name]
        chatter = withChatter
        chatterIsOnline = withChatter.isOnline
        isReadStatus = false
    }
    
    init(withDictionary: [String: Any]) {
        type = withDictionary["type"] as! String
        isReadStatus = withDictionary["isReadStatus"] as! Bool
        lastMessageTime = (withDictionary["lastMessageTime"] as! Timestamp).dateValue()
        userUids = withDictionary["userUids"] as! [String]
        userNames = withDictionary["userNames"] as! [String]
        uid = withDictionary["uid"] as! String
        fetchChatter{}
    }
    
    // MARK:- Methods
    
    public func toDict() -> [String: Any] {
        let data: [String: Any] = ["userNames": [CurrentUser.shared.user?.name, chatter?.name],
                                   "userUids": [CurrentUser.shared.user?.uid, chatter?.uid],
                                   "type": "private",
                                   "isReadStatus": false,
                                   "lastMessageTime": Timestamp(date: Date()),
                                   "uid": uid,
                                   "isChatterOnline": chatterIsOnline ?? false]
        return data
    }
    
    public func fetchChatter(completion: @escaping ()->()) {
        let chatterUid = CurrentUser.shared.user?.uid == userUids[0] ? userUids[1] : userUids[0]
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
