//
//  MessagesController.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MessagesController:   UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var chatterNameLabel: UILabel!
    @IBOutlet weak var chatterProfileImageView: CircularImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: AuthenticationTextField!
    @IBOutlet weak var textEntryBottomConstraint: NSLayoutConstraint!
    
    // MARK:- Properties
    
    let reuseId = "MessageCell"
    var messages = [[Message]]()
    var conversationListener: ListenerRegistration?
    var conversationStatusListener: ListenerRegistration?
    var conversation: Conversation?
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewConfig()
        setupMessageListener()
        setupConverstationStatusListener()
        
        guard let chatter = conversation?.chatter else {return}
        chatterProfileImageView.layer.borderWidth = chatter.isOnline ? 2 : 0
        chatterProfileImageView.image = chatter.profileImage
        chatterNameLabel.text = chatter.name
        
        registerForKeyboardWillShow()
        registerForKeyboardWillHide()
        setupTapToDismissKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        conversationListener?.remove()
        conversationStatusListener?.remove()
    }
    
    // MARK:- Methods
    
    fileprivate func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuseId)
    }
    
    fileprivate func scrollToBottomOfMessages() {
        if messages.count > 0 {
            let row = messages[messages.count-1].count-1
            let section = messages.count-1
            tableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: true)
        }
    }
    
    fileprivate func animateAddNewMessage(_ isNewSection: Bool) {
        let row = messages[messages.count-1].count-1
        let section = messages.count-1
        if isNewSection {
            tableView.insertSections([section], with: .fade)
        } else {
            tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .fade)
        }
    }
    
    fileprivate func setupConverstationStatusListener() {
        conversationStatusListener = UserMessagesManager.shared.listenForConversationChanges(conversaion: conversation!, completion: { (conversation) in
            if let conversation = conversation, self.isViewLoaded {
                conversation.fetchChatter{
                    guard let isOnline = conversation.chatter?.isOnline else {return}
                    self.chatterProfileImageView.layer.borderWidth = isOnline ? 2 : 0
                }
            }
        })
    }
    
    fileprivate func setupMessageListener() {
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
    
    fileprivate func groupMessagesByDate(_ messages: [Message]) -> [[Message]]? {
        let calendar = Calendar.current
        if self.messages.count == 0 {
            var sortedAndGroupedMessages = [[Message]]()
            let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
                return calendar.startOfDay(for: element.timestamp)
            }
            let sortedKeys = groupedMessages.keys.sorted()
            sortedKeys.forEach { (key) in
                let messagesForDate = groupedMessages[key]
                let sortedMessages = messagesForDate?.sorted(by: { (message1, message2) -> Bool in
                    return message1.timestamp < message2.timestamp
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
                self.textEntryBottomConstraint.constant = -keyboardHeight
                self.view.layoutIfNeeded()
            }
            scrollToBottomOfMessages()
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.textEntryBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        keyboardIsHidden = true
    }
    
    // MARK:- TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateLabel = DateHeader()
        dateLabel.date = messages[section][0].timestamp
        
        let containerView = UIView()
        containerView.addSubview(dateLabel)
        dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        return containerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as! MessageCell
        cell.message = messages[indexPath.section][indexPath.row]
        return cell
    }
    
    // MARK:- @IBActions
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func vibeButtonPressed(_ sender: UIButton) {
        print("Vibe button pressed")
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let conversation = conversation else {return}
        if messageTextField.text != "" {
            if let text = messageTextField.text, let toUid = conversation.chatter?.uid, let fromUid = CurrentUser.shared.data?.uid {
                messageTextField.text = ""
                UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
                    let message = Message(text: text, toUid: toUid, fromUid: fromUid, timestamp: Date(), threadId: conversation.uid)
                    UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                        MessagingManager.shared.uploadMessage(message: message) {}
                    }
                }
            }
        }
    }
    
}
