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
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        self.type = .imageMessage
        self.imageUrl = imageUrl
    }
    
    override init(withDictionary: [String: Any]) {
        super.init(withDictionary: withDictionary)
        self.type = .imageMessage
        if let imageUrlString = withDictionary["imageUrl"] as? String {
            self.imageUrl = URL(string: imageUrlString)
        }
    }
    
    // MARK:- Handlers
    
    public func toDict() -> [String : Any] {
        var dict = dictionaryRepresentation()
        if let imageUrl = self.imageUrl {
            dict["imageUrl"] = imageUrl.absoluteString
        }
        return dict
    }
    
    
}

