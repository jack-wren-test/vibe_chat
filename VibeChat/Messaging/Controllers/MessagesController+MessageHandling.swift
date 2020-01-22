//
//  MessagesController+MessageHandling.swift
//  VibeChat
//
//  Created by Jack Smith on 16/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension MessagesController {
    
    public func checkForConversationAndSendTextMessage(_ conversation: Conversation, _ text: String, _ toUid: String, _ fromUid: String) {
        if messages.count == 0 {
            UserMessagesManager.shared.createConversation(conversation: conversation) { [weak self] success in
                guard let self = self else {return}
                if success {
                    self.sendTextMessage(text, toUid, fromUid, conversation)
                }
            }
        } else {
            self.sendTextMessage(text, toUid, fromUid, conversation)
        }
    }
    
    private func sendTextMessage(_ text: String, _ toUid: String, _ fromUid: String, _ conversation: Conversation) {
        let message = TextMessage(text: text, toUid: toUid, fromUid: fromUid, timestamp: Date(), conversationId: conversation.uid)
        UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
            MessagingManager.shared.uploadMessage(message: message)
        }
    }
    
    public func setupMessageListener() {
        guard let conversation = conversation else {return}
        conversationListener = MessagingManager.shared.listenForMessages(onConversation: conversation) { [weak self] newMessages in
            guard let self = self, let newMessages = newMessages else {return}
            let isFirstTimeLoading = self.messages.count == 0 ? true : false
            if isFirstTimeLoading {
                self.organiseAndDisplayExistingMessages(newMessages)
            } else {
                self.organiseAndDisplayNewMessages(newMessages)
            }
        }
    }
    
    func organiseAndDisplayNewMessages(_ newMessages: [Message]) {
        let organiser = MessageOrganiser(newMessages: newMessages, existingMessages: self.messages)
        guard let messages = organiser.organiseMessages() else { return }
        let isSection = self.messages.count != messages.count
        self.messages = messages
        self.animateAddNewMessage(isSection)
        self.conversation?.isReadStatus = true
    }
    
    private func organiseAndDisplayExistingMessages(_ newMessages: [Message]) {
        let organiser = MessageOrganiser(newMessages: newMessages, existingMessages: nil)
        guard let messages = organiser.organiseMessages() else { return }
        self.messages = messages
        collectionView.reloadData()
        scrollToBottomOfMessages()
        conversation?.isReadStatus = true
    }
    
    private func animateAddNewMessage(_ isNewSection: Bool) {
        let row = messages[messages.count-1].count-1
        let section = messages.count-1
        if isNewSection {
            self.collectionView.insertSections([section])
        } else {
            self.collectionView.insertItems(at: [IndexPath(row: row, section: section)])
        }
        self.scrollToBottomOfMessages()
    }
    
    public func scrollToBottomOfMessages() {
        if self.messages.count > 0 {
            let contentHeight: CGFloat = self.collectionView.contentSize.height
            let heightAfterInserts: CGFloat = self.collectionView.frame.size.height - (self.collectionView.contentInset.top + self.collectionView.contentInset.bottom)
            if contentHeight > heightAfterInserts {
                self.collectionView.setContentOffset(CGPoint(x: 0, y: self.collectionView.contentSize.height - self.collectionView.frame.size.height), animated: true)
            }
        }
    }
    
}
