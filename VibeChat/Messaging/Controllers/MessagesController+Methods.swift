//
//  MessagesController+Methods.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension MessagesController {
    
    func sendTextMessage(_ conversation: Conversation, _ text: String, _ toUid: String, _ fromUid: String) {
        UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
            let message = TextMessage(text: text, toUid: toUid, fromUid: fromUid, timestamp: Date(), threadId: conversation.uid)
            UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                MessagingManager.shared.uploadMessage(message: message)
            }
        }
    }
    
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: textReuseId)
        tableView.register(ImageMessageCell.self, forCellReuseIdentifier: imageReuseId)
        tableView.register(GiphyMessageCell.self, forCellReuseIdentifier: giphyReuseId)
    }
    
    func scrollToBottomOfMessages() {
        if messages.count > 0 {
            let row = messages[messages.count-1].count-1
            let section = messages.count-1
            tableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: true)
        }
    }
    
    func animateAddNewMessage(_ isNewSection: Bool) {
        let row = messages[messages.count-1].count-1
        let section = messages.count-1
        if isNewSection {
            tableView.insertSections([section], with: .fade)
        } else {
            tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .fade)
        }
    }
    
    func setupConverstationStatusListener() {
        conversationStatusListener = UserMessagesManager.shared.listenForConversationChanges(conversaion: conversation!, completion: { (conversation) in
            if let conversation = conversation, self.isViewLoaded {
                conversation.fetchChatter{
                    guard let isOnline = conversation.chatter?.isOnline else {return}
                    self.chatterProfileImageView.layer.borderWidth = isOnline ? 2 : 0
                }
            }
        })
    }
    
    func setupMessageListener() {
        guard let conversation = conversation else {return}
        conversationListener = MessagingManager.shared.listenForMessages(onConversation: conversation) { (messages) in
            guard let messages = messages else {return}
            let daysOfMessagesCount = self.messages.count
            if let sortedMessages = self.groupMessagesByDate(messages) {
                self.messages = sortedMessages
                if self.isViewLoaded {
                    self.tableView.reloadData()
                    self.scrollToBottomOfMessages()
                    if conversation.hasDbCounterpart {self.conversation!.isReadStatus = true}
                    self.conversation!.isReadStatus = true
                }
            } else {
                if self.isViewLoaded {
                    let isSection = self.messages.count != daysOfMessagesCount
                    self.animateAddNewMessage(isSection)
                    self.scrollToBottomOfMessages()
                    if conversation.hasDbCounterpart {self.conversation!.isReadStatus = true}
                }
            }
        }
    }
    
    func groupMessagesByDate(_ messages: [Message]) -> [[Message]]? {
        let calendar = Calendar.current
        if self.messages.count == 0 {
            var sortedAndGroupedMessages = [[Message]]()
            let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
                return calendar.startOfDay(for: element.timestamp!)
            }
            let sortedKeys = groupedMessages.keys.sorted()
            sortedKeys.forEach { (key) in
                let messagesForDate = groupedMessages[key]
                let sortedMessages = messagesForDate?.sorted(by: { (message1, message2) -> Bool in
                    return message1.timestamp! < message2.timestamp!
                })
                sortedAndGroupedMessages.append(sortedMessages ?? [])
            }
            return sortedAndGroupedMessages
        } else {
            if var todaysMessages = self.messages.last,
                let latestMessageTimestamp = self.messages.last?.first?.timestamp,
                let thisMessageTimestamp = messages.first?.timestamp,
                calendar.startOfDay(for: latestMessageTimestamp) == calendar.startOfDay(for: thisMessageTimestamp) {
                todaysMessages.append(contentsOf: messages)
                self.messages.removeLast()
                self.messages.append(todaysMessages)
            } else {
                self.messages.append(messages)
            }
        }
        return nil
    }
    
    override func animateViewWithKeyboard(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.5) {
                self.specialMessageLeadingConstraint.constant = 0
                self.specialMessageViewWidthConstraint.constant = 0
                self.textEntryBottomConstraint.constant = -keyboardHeight
                self.view.layoutIfNeeded()
            }
            scrollToBottomOfMessages()
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.specialMessageLeadingConstraint.constant = 10
            self.specialMessageViewWidthConstraint.constant = 110
            self.textEntryBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        keyboardIsHidden = true
    }
    
}
