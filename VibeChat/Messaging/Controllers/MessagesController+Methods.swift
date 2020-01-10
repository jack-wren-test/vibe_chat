//
//  MessagesController+Methods.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension MessagesController {
    
    func setupProfileButton() {
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleProfileTapped), for: .touchUpInside)
        
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: chatterProfileImageView.leadingAnchor).isActive = true
        button.topAnchor.constraint(equalTo: chatterProfileImageView.topAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: chatterProfileImageView.trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: chatterNameLabel.bottomAnchor).isActive = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatterProfileController, let chatter = conversation?.chatter {
            vc.chatter = chatter
        }
    }
    
    @objc fileprivate func handleProfileTapped() {
        performSegue(withIdentifier: "chatterProfileSegue", sender: self)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func sendTextMessage(_ conversation: Conversation, _ text: String, _ toUid: String, _ fromUid: String) {
        UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
            let message = TextMessage(text: text, toUid: toUid, fromUid: fromUid, timestamp: Date(), threadId: conversation.uid)
            UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                MessagingManager.shared.uploadMessage(message: message)
            }
        }
    }
    
    func collectionViewConfig() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseId)
        collectionView.register(TextMessageCell.self, forCellWithReuseIdentifier: textReuseId)
        collectionView.register(ImageMessageCell.self, forCellWithReuseIdentifier: imageReuseId)
        collectionView.register(GiphyMessageCell.self, forCellWithReuseIdentifier: giphyReuseId)
        collectionView.register(VideoMessageCell.self, forCellWithReuseIdentifier: videoReuseId)
    }
    
    func scrollToBottomOfMessages() {
        if messages.count > 0 {
            let contentHeight: CGFloat = collectionView.contentSize.height
            let heightAfterInserts: CGFloat = collectionView.frame.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)
            if contentHeight > heightAfterInserts {
                collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentSize.height - collectionView.frame.size.height), animated: true)
            }
        }
    }
    
    func animateAddNewMessage(_ isNewSection: Bool) {
        let row = messages[messages.count-1].count-1
        let section = messages.count-1
        if isNewSection {
            collectionView.insertSections([section])
        } else {
            collectionView.insertItems(at: [IndexPath(row: row, section: section)])
        }
    }
    
    func setupConverstationStatusListener() {
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
    
    func setupMessageListener() {
        guard let conversation = conversation else {return}
        conversationListener = MessagingManager.shared.listenForMessages(onConversation: conversation) { (messages) in
            guard let messages = messages else {return}
            let daysOfMessagesCount = self.messages.count
            if let sortedMessages = self.groupMessagesByDate(messages) {
                self.messages = sortedMessages
                if self.isViewLoaded {
                    self.collectionView.reloadData()
                    if conversation.hasDbCounterpart {self.conversation!.isReadStatus = true}
                    self.conversation!.isReadStatus = true
                }
            } else {
                if self.isViewLoaded {
                    let isSection = self.messages.count != daysOfMessagesCount
                    self.animateAddNewMessage(isSection)
                    if conversation.hasDbCounterpart {self.conversation!.isReadStatus = true}
                }
            }
            self.scrollToBottomOfMessages()
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
