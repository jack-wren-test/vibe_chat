//
//  TextMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Class for text message cell.
class TextMessageCell: MessageCell {
    
    // MARK:- Properties
    
    let messageLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bubbleView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var textMessage: TextMessage? {
        didSet {
            guard let user = CurrentUser.shared.data else {return}
            guard let message = textMessage else {return}
            messageLabel.text = message.text
            let isOutgoingMessage = message.fromUid == user.uid
            layoutMessage(isOutgoingMessage)
        }
    }
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        messageLabel.text = nil
        textMessage = nil
    }
    
    // MARK:- Methods
    
    fileprivate func configureViews() {
        addSubview(bubbleView)
        addSubview(messageLabel)
        
        incomingXConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        outgoingXConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        
        bubbleView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -10).isActive = true
        bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 10).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10).isActive = true
    }
    
    override func layoutMessage(_ isOutgoingMessage: Bool) {
        if isOutgoingMessage {
            bubbleView.backgroundColor = UIColor(named: "text_alt")
            messageLabel.textColor = UIColor(named: "background_alt")
            incomingXConstraint?.isActive = false
            outgoingXConstraint?.isActive = true
        } else {
            bubbleView.backgroundColor = UIColor.systemGray
            messageLabel.textColor = UIColor(named: "background_alt")
            outgoingXConstraint?.isActive = false
            incomingXConstraint?.isActive = true
        }
    }
    
}

