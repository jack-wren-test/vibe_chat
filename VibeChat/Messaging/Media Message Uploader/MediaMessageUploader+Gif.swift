//
//  MediaMessageUploader+Gif.swift
//  VibeChat
//
//  Created by Jack Smith on 16/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import Firebase

extension MediaMessageUploader {
    
    /// Check for existing conversation in db (create one if it doesn't exist), and send giphy message.
    /// - Parameters:
    ///   - conversation: The conversation to create and send the message to
    ///   - withGiphId: The giphy id to send
    ///   - andAspectRatio: The aspect ratio of the gif
    ///   - completion: Completion handler passing a success truth value
    public func checkForConversationAndSendGiphyMessage(onConversation conversation: Conversation,
                                                        withGiphId: String,
                                                        andAspectRatio: CGFloat,
                                                        completion: @escaping (_ success: Bool)->Void) {
        guard let currentUser = CurrentUser.shared.data else {return}
        if self.isFirstMessage {
            UserMessagesManager.shared.createConversation(conversation: conversation) { [weak self] success in
                guard let self = self, success else {return}
                self.sendGiphyMessage(withGiphId, andAspectRatio, conversation, currentUser, completion)
            }
        } else {
            self.sendGiphyMessage(withGiphId, andAspectRatio, conversation, currentUser, completion)
        }
    }
    
    /// Creates and sends a GiphyMessage
    /// - Parameters:
    ///   - withGiphId: The giphy id to send
    ///   - andAspectRatio: The aspect ratio of the gif
    ///   - conversation: The conversation to create and send the message to
    ///   - currentUser: The currently logged in user
    ///   - completion: Completion handler passing a success truth value
    private func sendGiphyMessage(_ withGiphId: String,
                                 _ andAspectRatio: CGFloat,
                                 _ conversation: Conversation,
                                 _ currentUser: User,
                                 _ completion: @escaping (_ success: Bool)->Void) {
        guard let chatter = conversation.chatter else {return}
        let message = GiphyMessage(giphId: withGiphId, aspectRatio: andAspectRatio, toUid: chatter.uid, fromUid: currentUser.uid, timestamp: Date(), conversationId: conversation.uid)
        UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
            MessagingManager.shared.uploadMessage(message: message) { (success) in
                completion(success)
            }
        }
    }
    
}
