//
//  MessagesController.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import FirebaseFirestore
import GiphyUISDK

protocol messagesControllerDelegate {
    func imageMessageTapped(_ imageView: UIImageView)
}

class MessagesController:   UIViewController {
    
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var chatterNameLabel: UILabel!
    @IBOutlet weak var chatterProfileImageView: CircularImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageTextField: AuthenticationTextField!
    @IBOutlet weak var textEntryBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var specialMessageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var specialMessageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBarWidthAnchor: NSLayoutConstraint!
    
    // MARK:- Properties
    
    let headerReuseId = "headerView"
    let textReuseId = "textMessageCell"
    let imageReuseId = "imageMessageCell"
    let videoReuseId = "videoMessageCell"
    let giphyReuseId = "giphyMessageCell"
    
    var messages = [[Message]]()
    var conversationListener: ListenerRegistration?
    var conversationStatusListener: ListenerRegistration?
    var conversation: Conversation?
    
    var startingImageView: UIImageView?
    var imageStartingFrame: CGRect?
    var backgroundView: UIView?
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GiphyUISDK.configure(apiKey: "vXS5bLeyzx4cOUgU9RVheieQLWXmVRoY")
        
        collectionViewConfig()
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
    
    deinit {
        print("Messages controller deinitialised")
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
                sendTextMessage(conversation, text, toUid, fromUid)
            }
        }
    }
    
}
