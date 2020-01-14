//
//  MessagesController+Methods.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension MessagesController {
    
    public func configureInitialChatterHeader() {
        guard let chatter = conversation?.chatter else {return}
        chatterProfileImageView.layer.borderWidth = chatter.isOnline ? 2 : 0
        chatterProfileImageView.image = chatter.profileImage
        chatterNameLabel.text = chatter.name
        setupProfileButton()
    }
    
    public func setupProfileButton() {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleProfileTapped), for: .touchUpInside)
        
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: chatterProfileImageView.leadingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: chatterProfileImageView.topAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: chatterProfileImageView.trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: chatterNameLabel.bottomAnchor).isActive = true
    }
    
    @objc fileprivate func handleProfileTapped() {
        performSegue(withIdentifier: "chatterProfileSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatterProfileController, let chatter = conversation?.chatter {
            vc.chatter = chatter
        }
    }
    
    public func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    public func sendTextMessage(_ conversation: Conversation, _ text: String, _ toUid: String, _ fromUid: String) {
        UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
            let message = TextMessage(text: text, toUid: toUid, fromUid: fromUid, timestamp: Date(), threadId: conversation.uid)
            UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                MessagingManager.shared.uploadMessage(message: message)
            }
        }
    }
    
    public func collectionViewConfig() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseId)
        collectionView.register(TextMessageCell.self, forCellWithReuseIdentifier: textReuseId)
        collectionView.register(ImageMessageCell.self, forCellWithReuseIdentifier: imageReuseId)
        collectionView.register(GiphyMessageCell.self, forCellWithReuseIdentifier: giphyReuseId)
        collectionView.register(VideoMessageCell.self, forCellWithReuseIdentifier: videoReuseId)
    }
    
    public func scrollToBottomOfMessages() {
        if messages.count > 0 {
            let contentHeight: CGFloat = collectionView.contentSize.height
            let heightAfterInserts: CGFloat = collectionView.frame.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)
            if contentHeight > heightAfterInserts { // Don't scroll if content is smaller than the view height8
                collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentSize.height - collectionView.frame.size.height), animated: true)
            }
        }
    }
    
    public func animateAddNewMessage(_ isNewSection: Bool) {
        let row = messages[messages.count-1].count-1
        let section = messages.count-1
        if isNewSection {
            collectionView.insertSections([section])
        } else {
            collectionView.insertItems(at: [IndexPath(row: row, section: section)])
        }
        self.scrollToBottomOfMessages()
    }
    
    public func setupConverstationStatusListener() {
        conversationStatusListener = UserMessagesManager.shared.listenForConversationChanges(conversaion: conversation!, completion: { (conversation) in
            if let conversation = conversation, self.isViewLoaded {
                conversation.fetchChatter { (success) in
                    if success, let isOnline = conversation.chatter?.isOnline {
                        self.chatterProfileImageView.layer.borderWidth = isOnline ? 2 : 0
                    }
                }
            }
        })
    }
    
    public func setupMessageListener() {
        guard let conversation = conversation else {return}
        conversationListener = MessagingManager.shared.listenForMessages(onConversation: conversation) { (messages) in
            guard let messages = messages else {return}
            let daysOfMessagesCount = self.messages.count
            let sortedMessages = self.groupMessagesByDate(messages)
            guard let sortedAndGroupedMessages = sortedMessages else {
                if self.isViewLoaded { // Shouldn't have to do this if message listeners are properly removed, test.
                    // self.messages.count will be increased if
                    // it's a new day since the last message so we need to add a section
                    let isSection = self.messages.count != daysOfMessagesCount
                    self.animateAddNewMessage(isSection)
                    if conversation.hasDbCounterpart {self.conversation!.isReadStatus = true}
                }
                return
            }
            self.messages = sortedAndGroupedMessages
            if self.isViewLoaded {
                self.collectionView.reloadData()
                if conversation.hasDbCounterpart {self.conversation!.isReadStatus = true}
                self.conversation!.isReadStatus = true
                self.scrollToBottomOfMessages()
            }
        }
    }
    
    public func groupMessagesByDate(_ messages: [Message]) -> [[Message]]? {
        let calendar = Calendar.current
        let isFirstTimeLoading = self.messages.count == 0 ? true : false
        if isFirstTimeLoading {
            let sortedAndGroupedMessages = sortAndGroupMessages(messages, calendar)
            return sortedAndGroupedMessages
        } else {
            if isSameDay(messages, calendar) {
                var todaysMessages = self.messages.last!
                todaysMessages.append(contentsOf: messages)             // Append new messages to today
                self.messages[self.messages.count-1] = todaysMessages   // Update instance variable
            } else {
                self.messages.append(messages)                          // Is a new day, simply add the new array of messages
            }
        }
        return nil
    }
    
    fileprivate func isSameDay(_ messages: [Message], _ calendar: Calendar) -> Bool {
        if  let todaysMessages = self.messages.last,
            let latestMessageTimestamp = todaysMessages.first?.timestamp,
            let thisMessageTimestamp = messages.first?.timestamp,
            calendar.startOfDay(for: latestMessageTimestamp) == calendar.startOfDay(for: thisMessageTimestamp) {
            return true
        }
        return false
    }
    
    fileprivate func sortAndGroupMessages(_ messages: [Message], _ calendar: Calendar) -> [[Message]]? {
        var sortedAndGroupedMessages = [[Message]]()
        
        // First, group by days
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            return calendar.startOfDay(for: element.timestamp!)
        }
        
        // Second, order by date
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let messagesForDate = groupedMessages[key]
            let sortedMessages = messagesForDate?.sorted(by: { (message1, message2) -> Bool in
                return message1.timestamp! < message2.timestamp!
            })
            sortedAndGroupedMessages.append(sortedMessages ?? [])
        }
        return sortedAndGroupedMessages
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
