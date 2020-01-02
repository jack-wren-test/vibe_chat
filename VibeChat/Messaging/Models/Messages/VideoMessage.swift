//
//  VideoMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 31/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation
import Firebase

class VideoMessage: Message {
    
    // MARK:- Properties
    
    var videoUrl:           URL?
    var thumbnailImageUrl:  URL?
    var aspectRatio:        CGFloat?
    
    // MARK:- Init
    
    init(videoUrl: URL, thumbnailImageUrl: URL, aspectRatio: CGFloat, toUid: String, fromUid: String, timestamp: Date, threadId: String) {
        super.init(text: "", toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        self.videoUrl = videoUrl
        self.thumbnailImageUrl = thumbnailImageUrl
        self.aspectRatio = aspectRatio
    }
    
    override init(withDictionary: [String: Any]) {
        super.init(withDictionary: withDictionary)
        if let videoUrlString = withDictionary["videoUrl"] as? String {
            self.videoUrl = URL(string: videoUrlString)
        }
        if let thumbnailImageUrlString = withDictionary["thumbnailImageUrl"] as? String {
            self.thumbnailImageUrl = URL(string: thumbnailImageUrlString)
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
        if let videoUrl = self.videoUrl { dict["videoUrl"] = videoUrl.absoluteString }
        if let thumbnailImageUrl = self.thumbnailImageUrl { dict["thumbnailImageUrl"] = thumbnailImageUrl.absoluteString }
        if let aspectRatio = self.aspectRatio { dict["aspectRatio"] = aspectRatio }
        return dict
    }
    
}
