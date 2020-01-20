//
//  MessagesController+TextView.swift
//  VibeChat
//
//  Created by Jack Smith on 20/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension MessagesController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        messageInput.hidePlaceholder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if messageInput.text == "" {
            messageInput.showPlaceholder()
        } else {
            messageInput.hidePlaceholder()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: self.messageInputWidth, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        if estimatedSize.width >= self.messageInputWidth * 0.8 {
            UIView.animate(withDuration: 0.5) {
                self.specialMessageLeadingConstraint.constant = -110
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.specialMessageLeadingConstraint.constant = 10
                self.view.layoutIfNeeded()
            }
        }
        if estimatedSize.height >= 225 {
            messageInput.isScrollEnabled = true
            // scroll to bottom
        } else {
            messageInput.isScrollEnabled = false
        }
    }
    
}
