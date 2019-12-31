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
        super.init(text: nil, toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        self.giphId = giphId
    }
    
    override init(withDictionary: [String : Any]) {
        super.init(withDictionary: withDictionary)
        giphId = withDictionary["giphId"] as? String
    }
    
    // MARK:- Methods
    
    override func toDict() -> [String : Any] {
        let tStamp = Timestamp.init(date: timestamp ?? Date())
        var dict: [String: Any] = ["text": text ?? "",
                                   "toUid": toUid ?? "",
                                   "fromUid": fromUid ?? "",
                                   "threadId": conversationId ?? "",
                                   "timestamp": tStamp]
        if let giphId = self.giphId {
            dict["giphId"] = giphId
        }
        return dict
    }
    
    
}
