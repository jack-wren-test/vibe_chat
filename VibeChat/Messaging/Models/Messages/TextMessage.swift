//
//  TextMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import Foundation

final class TextMessage: Message {
    
    // MARK:- Properties
    
    var text:   String?
    
    // MARK:- Init
    
    init(text: String, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        setType(type: .textMessage)
        self.text = text
    }
    
    override init(withDictionary: [String: Any]) {
        super.init(withDictionary: withDictionary)
        setType(type: .textMessage)
        if let text = withDictionary["text"] as? String {
            self.text = text
        }
    }
    
    // MARK:- Methods
    
    override func toDict() -> [String: Any] {
        var dict = dictionaryRepresentation()
        if let text = self.text {
            dict["text"] = text
        }
        return dict
    }
    
}
