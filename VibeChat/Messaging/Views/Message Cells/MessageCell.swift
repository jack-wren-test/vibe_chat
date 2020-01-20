//
//  MessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Base class for a message cell.
class MessageCell: UICollectionViewCell {
    
    // MARK:- Properties
    
    let maxMessageWidth: CGFloat = 225
    let cellBuffer: CGFloat = 2
    let edgeBuffer: CGFloat = 10
    
    var message: Message? {
        didSet {
            setupMessage()
        }
    }
    
    var incomingXConstraint: NSLayoutConstraint?
    var outgoingXConstraint: NSLayoutConstraint?
    var viewHeightAnchor: NSLayoutConstraint?
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        self.viewHeightAnchor = nil
    }
    
    // MARK:- Methods
    
    public func setupMessage() {
        guard let message = message, let user = CurrentUser.shared.data else {return}
        let isOutgoingMessage = message.fromUid == user.uid
        self.layoutMessage(isOutgoingMessage)
    }
    
    public func layoutMessage(_ isOutgoingMessage: Bool) {
        if isOutgoingMessage {
            self.incomingXConstraint?.isActive = false
            self.outgoingXConstraint?.isActive = true
        } else {
            self.outgoingXConstraint?.isActive = false
            self.incomingXConstraint?.isActive = true
        }
    }
    
}
