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
        super.init(toUid: toUid, fromUid: fromUid, timestamp: timestamp, threadId: threadId)
        self.type = .videoMessage
        self.videoUrl = videoUrl
        self.thumbnailImageUrl = thumbnailImageUrl
        self.aspectRatio = aspectRatio
    }
    
    override init(withDictionary: [String: Any]) {
        super.init(withDictionary: withDictionary)
        self.type = .videoMessage
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
    
    public func toDict() -> [String : Any] {
        var dict = dictionaryRepresentation()
        if let videoUrl = self.videoUrl { dict["videoUrl"] = videoUrl.absoluteString }
        if let thumbnailImageUrl = self.thumbnailImageUrl { dict["thumbnailImageUrl"] = thumbnailImageUrl.absoluteString }
        if let aspectRatio = self.aspectRatio { dict["aspectRatio"] = aspectRatio }
        return dict
    }
    
}
