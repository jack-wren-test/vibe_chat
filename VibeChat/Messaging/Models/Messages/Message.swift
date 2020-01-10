//
//  Message.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

/// Enummeration for message types.
enum MessageType {
    case textMessage, videoMessage, imageMessage, giphyMessage
}

/// Base model for a message.
class Message {
    
    // MARK:- Properties
    
    private(set) var type: MessageType?
    var dictionaryRepresentation: [String: Any]!
    var toUid: String?
    var fromUid: String?
    var timestamp: Date?
    var conversationId: String?
    
    // MARK:- Init
    
    init(toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        self.toUid = toUid
        self.fromUid = fromUid
        self.timestamp = timestamp
        self.conversationId = threadId
        dictionaryRepresentation = toDict()
    }
    
    init(withDictionary: [String: Any]) {
        toUid = withDictionary["toUid"] as? String
        fromUid = withDictionary["fromUid"] as? String
        conversationId = withDictionary["threadId"] as? String
        if let timestamp = withDictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        }
        dictionaryRepresentation = toDict()
    }
    
    // MARK:- Methods
    
    public func setType(type: MessageType) {
        self.type = type
    }
    
    private func toDict() -> [String: Any] {
        let tStamp = Timestamp.init(date: timestamp ?? Date())
        let dict: [String: Any] = ["toUid": toUid ?? "",
                                   "fromUid": fromUid ?? "",
                                   "threadId": conversationId ?? "",
                                   "timestamp": tStamp]
        return dict
    }
    
}
