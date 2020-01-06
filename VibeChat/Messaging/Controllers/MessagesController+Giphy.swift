//
//  MessagesController+Giphy.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit
import GiphyUISDK
import GiphyCoreSDK

extension MessagesController: GiphyDelegate {
    
    // MARK:- Methods
    
    func didDismiss(controller: GiphyViewController?) {}
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        print("Sending aspect ratio: \(media.aspectRatio)")
        sendGiphyMessage(withGiphId: media.id, andAspectRatio: media.aspectRatio) {
            giphyViewController.dismiss(animated: true)
        }
    }
    
    fileprivate func sendGiphyMessage(withGiphId: String, andAspectRatio: CGFloat, completion: @escaping ()->()) {
        guard let conversation = conversation else {return}
        UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
            let message = GiphyMessage(giphId: withGiphId, aspectRatio: andAspectRatio, toUid: conversation.chatter!.uid, fromUid: CurrentUser.shared.data!.uid, timestamp: Date(), threadId: conversation.uid)
            UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                MessagingManager.shared.uploadMessage(message: message) {
                    print("Giphy message uploaded with gif ID: \(message.giphId!)")
                    completion()
                }
            }
        }
    }
    
    // MARK:- IBActions
    
    @IBAction func giphyButtonPressed(_ sender: Any) {        
        let giphy = GiphyViewController()
        giphy.delegate = self
        if self.traitCollection.userInterfaceStyle == .dark {
            giphy.theme = .dark
        }
        present(giphy, animated: true)
    }
    
}
