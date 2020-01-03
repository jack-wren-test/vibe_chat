//
//  giphyMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

class GiphyMessage: Message {
    
    // MARK:- Properties
    
    var giphId: String?
    
    // MARK:- Init
    
    init(giphId: String, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        setType(type: .giphyMessage)
        self.giphId = giphId
    }
    
    override init(withDictionary: [String : Any]) {
        super.init(withDictionary: withDictionary)
        setType(type: .giphyMessage)
        giphId = withDictionary["giphId"] as? String
    }
    
    // MARK:- Methods
    
    override func toDict() -> [String : Any] {
        var dict = dictionaryRepresentation()
        if let giphId = self.giphId {
            dict["giphId"] = giphId
        }
        return dict
    }
    
}
