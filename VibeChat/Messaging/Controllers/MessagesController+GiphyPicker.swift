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
        guard let conversation = self.conversation else {return}
        let isFirstMessage = self.messages.count == 0 ? true : false
        let messageUploader = MediaMessageUploader(gif: media,
                                                   conversation: conversation,
                                                   isFirstMessage: isFirstMessage)
        let _ = messageUploader.uploadMessage { success in
            if !success {
                print("Error uploading GIF!")
            }
            giphyViewController.dismiss(animated: true)
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
