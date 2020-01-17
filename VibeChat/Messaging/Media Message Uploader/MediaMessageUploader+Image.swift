//
//  MediaMessageUploader+Image.swift
//  VibeChat
//
//  Created by Jack Smith on 16/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import Firebase

extension MediaMessageUploader {
    
    /// Upload image to storage and send image message.
    /// - Parameters:
    ///   - image: The image to send
    ///   - onConversation: The conversation to send to
    ///   - aspectRatio: The aspect ratio of the image
    ///   - completion: Completion handler passing a success truth value
    public func uploadImageMessage(image: UIImage,
                                   onConversation: Conversation,
                                   aspectRatio: CGFloat,
                                   completion: @escaping (_ success: Bool)->Void) -> StorageUploadTask? {
        let uploadTask = StorageManager.shared.uploadImageMessage(image: image) { (url) in
            guard let url = url else {return}
            self.checkForConversationAndSendImageMessage(onConversation: onConversation, imageUrl: url, andAspectRatio: aspectRatio) { (success) in
                completion(success)
            }
        }
        return uploadTask
    }
    
    /// Check for existing conversation in db (create one if it doesn't exist), and send image message.
    /// - Parameters:
    ///   - conversation: The conversation
    ///   - imageUrl: The db Url for the image
    ///   - andAspectRatio: The aspect ratio of the image
    ///   - completion: Completion handler passing a success truth value
    private func checkForConversationAndSendImageMessage(onConversation conversation: Conversation,
                                                        imageUrl: URL,
                                                        andAspectRatio: CGFloat,
                                                        completion: @escaping (_ success: Bool)->Void) {
        guard let currentUser = CurrentUser.shared.data else {return}
        if isFirstMessage {
            UserMessagesManager.shared.createConversation(conversation: conversation) { (success) in
                guard success else {return}
                self.sendImageMessage(imageUrl, andAspectRatio, conversation, currentUser, completion)
            }
        } else {
            sendImageMessage(imageUrl, andAspectRatio, conversation, currentUser, completion)
        }
    }
    
    /// Send image message.
    /// - Parameters:
    ///   - imageUrl: The db Url for the image
    ///   - andAspectRatio: The aspect ratio for the image
    ///   - conversation: The conversation to send the message to 
    ///   - currentUser: The currently logged in user
    ///   - completion: Completion handler passing a success truth value
    private func sendImageMessage(_ imageUrl: URL,
                                 _ andAspectRatio: CGFloat,
                                 _ conversation: Conversation,
                                 _ currentUser: User,
                                 _ completion: @escaping (_ success: Bool)->Void) {
        
        let message = ImageMessage(imageUrl: imageUrl,
                                   aspectRatio: andAspectRatio,
                                   toUid: conversation.chatter!.uid,
                                   fromUid: currentUser.uid,
                                   timestamp: Date(),
                                   conversationId: conversation.uid)
        
        UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
            print("Sending Image Message!")
            MessagingManager.shared.uploadMessage(message: message, completion: completion)
        }
    }
    
}
