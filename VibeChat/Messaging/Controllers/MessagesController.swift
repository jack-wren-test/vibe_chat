//
//  MessagesController.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import Firebase
import GiphyUISDK
import AVFoundation

/// Controller for the messages view.
class MessagesController: UIViewController {
    
    // MARK:- IBOutlets
    
    @IBOutlet public weak var chatterNameLabel: UILabel!
    @IBOutlet public weak var chatterProfileImageView: CircularImageView!
    @IBOutlet public weak var collectionView: UICollectionView!
    @IBOutlet public weak var messageInput: ExpandingTextInput!
    @IBOutlet public weak var textEntryBottomConstraint: NSLayoutConstraint!
    @IBOutlet public weak var specialMessageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet public weak var specialMessageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet public weak var progressBarWidthAnchor: NSLayoutConstraint!
    
    // MARK:- Properties
    
    let headerReuseId = "headerView"
    
    var messages = [[Message]]()
    var organiser: MessageOrganiser?
    var conversationListener: ListenerRegistration?
    var conversationStatusListener: ListenerRegistration?
    var conversation: Conversation?
    
    var zoomingView: UIView?
    var initialMediaMessageFrame: CGRect?
    var backgroundView: UIView?
    lazy var messageInputWidth = messageInput.frame.width
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GiphyUISDK.configure(apiKey: "vXS5bLeyzx4cOUgU9RVheieQLWXmVRoY")
        
        self.configureInitialChatterHeader()
        self.collectionViewConfig()
        self.setupMessageListener()
        self.setupConverstationStatusListener()

        self.registerForKeyboardWillShow()
        self.registerForKeyboardWillHide()
        self.setupTapToDismissKeyboard()

        self.messageInput.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollToBottomOfMessages()
    }
    
    deinit {
        self.conversationListener?.remove()
        self.conversationStatusListener?.remove()
    }
    
    // MARK:- @IBActions
    
    @IBAction private func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func sendButtonPressed(_ sender: UIButton) {
        guard let conversation = self.conversation else {return}
        guard let text = self.messageInput.text else {return}
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if  let toUid = conversation.chatter?.uid,
                let fromUid = CurrentUser.shared.data?.uid {
                self.messageInput.text = ""
                self.checkForConversationAndSendTextMessage(conversation, text, toUid, fromUid)
            }
        }
    }
    
}
