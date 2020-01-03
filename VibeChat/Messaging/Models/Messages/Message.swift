//
//  Message.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

enum MessageType {
    case textMessage, videoMessage, imageMessage, giphyMessage
}

class Message: NSObject {
    
    // MARK:- Properties
    
    private(set) var type:  MessageType?
    var toUid:              String?
    var fromUid:            String?
    var timestamp:          Date?
    var conversationId:     String?
    
    // MARK:- Initializers
    
    init(toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        self.toUid = toUid
        self.fromUid = fromUid
        self.timestamp = timestamp
        self.conversationId = threadId
    }
    
    init(withDictionary: [String: Any]) {
        toUid = withDictionary["toUid"] as? String
        fromUid = withDictionary["fromUid"] as? String
        conversationId = withDictionary["threadId"] as? String
        if let timestamp = withDictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        }
    }
    
    // MARK:- Methods
    
    public func dictionaryRepresentation() -> [String: Any] {
        let tStamp = Timestamp.init(date: timestamp ?? Date())
        let dict: [String: Any] = ["toUid": toUid ?? "",
                                   "fromUid": fromUid ?? "",
                                   "threadId": conversationId ?? "",
                                   "timestamp": tStamp]
        return dict
    }
    
}
