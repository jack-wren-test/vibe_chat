//
//  MessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

// IS IT WORTH HAVING A VIEWMODEL FOR THIS CLASS DUE TO SEVERAL MODELS COMBINING? OR DEAL WITH IN MESSAGE CLASS

class MessageCell: UITableViewCell {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: BubbleView!
    
    // MARK:- Properties
    
    var message: Message? {
        didSet {
            guard let user = user else {return}
            guard let message = message else {return}
            messageLabel.text = message.text
            let isOutgoingMessage = message.fromUid == user.uid
            layoutMessage(isOutgoingMessage)
        }
    }
    
    var incomingXConstraint: NSLayoutConstraint?
    var outgoingXConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        configureCell()
    }
    
    // A message cell probably shouldn't have a user
    var user: User?
    
    // MARK:- Methods
    
    fileprivate func configureCell() {
        
        selectionStyle = .none
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        incomingXConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        outgoingXConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -10).isActive = true
        bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 10).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10).isActive = true
        
    }
    
    fileprivate func layoutMessage(_ isOutgoingMessage: Bool) {
        if isOutgoingMessage {
            bubbleView.backgroundColor = UIColor.appDark
            messageLabel.textColor = UIColor.white
            incomingXConstraint?.isActive = false
            outgoingXConstraint?.isActive = true
        } else {
            bubbleView.backgroundColor = UIColor.white
            messageLabel.textColor = UIColor.appDark
            outgoingXConstraint?.isActive = false
            incomingXConstraint?.isActive = true
        }
    }
    
    // TODO: Add ability to react to messages with a long/force press
    
}
