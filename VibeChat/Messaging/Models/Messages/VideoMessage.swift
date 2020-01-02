//
//  VideoMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 31/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

class VideoMessage: ImageMessage {
    
    // MARK:- Properties
    
    var thumbnailImageUrl:  String?
    var aspectRatio:        CGFloat?
    
    // MARK:- Init
    
    init(url: String, thumbnailImageUrl: String, aspectRatio: CGFloat, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        super.init(url: url, toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        self.thumbnailImageUrl = thumbnailImageUrl
        self.aspectRatio = aspectRatio
    }
    
    override init(withDictionary: [String: Any]) {
        super.init(withDictionary: withDictionary)
        if let thumbnailImageUrl = withDictionary["thumbnailImageUrl"] as? String {
            self.url = thumbnailImageUrl
        }
        if let aspectRatio = withDictionary["aspectRatio"] as? CGFloat {
            self.aspectRatio = aspectRatio
        }
    }
    
    // MARK:- Methods
    
    override func toDict() -> [String : Any] {
        let tStamp = Timestamp.init(date: timestamp ?? Date())
        var dict: [String: Any] = ["text": text ?? "",
                                   "toUid": toUid ?? "",
                                   "fromUid": fromUid ?? "",
                                   "threadId": conversationId ?? "",
                                   "timestamp": tStamp]
        if let url = self.url { dict["imageUrl"] = url }
        if let thumbnailImageUrl = self.thumbnailImageUrl { dict["thumbnailImageUrl"] = thumbnailImageUrl }
        if let aspectRatio = self.aspectRatio { dict["aspectRatio"] = aspectRatio }
        return dict
    }
    
}
