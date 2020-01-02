//
//  ImageMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

class ImageMessage: Message {
    
    // MARK:- Properties
    
    var imageUrl: URL?
    
    // MARK:- Init
    
    init(imageUrl: URL, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        super.init(text: nil, toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        self.imageUrl = imageUrl
    }
    
    override init(withDictionary: [String: Any]) {
        super.init(withDictionary: withDictionary)
        if let imageUrlString = withDictionary["imageUrl"] as? String {
            self.imageUrl = URL(string: imageUrlString)
        }
    }
    
    // MARK:- Handlers
    
    override func toDict() -> [String : Any] {
        let tStamp = Timestamp.init(date: timestamp ?? Date())
        var dict: [String: Any] = ["text": text ?? "",
                                   "toUid": toUid ?? "",
                                   "fromUid": fromUid ?? "",
                                   "threadId": conversationId ?? "",
                                   "timestamp": tStamp]
        if let imageUrl = self.imageUrl {
            dict["imageUrl"] = imageUrl.absoluteString
        }
        return dict
    }
    
    
}

