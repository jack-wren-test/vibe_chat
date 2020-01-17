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
        chatterNameLabel.text = chatter.name
        setupProfileButton()
        if let profileImageUrl = chatter.profileImageUrl {
            chatterProfileImageView.loadImageUsingCacheOrUrl(url: profileImageUrl)
        }
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
    
    public func collectionViewConfig() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseId)
        collectionView.register(TextMessageCell.self, forCellWithReuseIdentifier: MessageType.textMessage.reuseId)
        collectionView.register(ImageMessageCell.self, forCellWithReuseIdentifier: MessageType.imageMessage.reuseId)
        collectionView.register(GiphyMessageCell.self, forCellWithReuseIdentifier: MessageType.giphyMessage.reuseId)
        collectionView.register(VideoMessageCell.self, forCellWithReuseIdentifier: MessageType.videoMessage.reuseId)
    }
    
    public func setupConverstationStatusListener() {
        guard let conversation = conversation else {return}
        conversationStatusListener = UserMessagesManager.shared.listenForConversationChanges(conversaion: conversation,
                                                                                             completion: { [weak self] (conversation) in
            if let conversation = conversation {
                conversation.fetchChatter { (success) in
                    if success, let isOnline = conversation.chatter?.isOnline {
                        self?.chatterProfileImageView.layer.borderWidth = isOnline ? 2 : 0
                    }
                }
            }
        })
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
