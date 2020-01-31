//
//  TextMessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 30/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Class for text message cell.
final class TextMessageCell: MessageCell {
    
    // MARK:- Properties
    
    private let bubbleViewSpacing: CGFloat = 10
    
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
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        self.messageLabel.text = nil
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        self.addSubview(bubbleView)
        self.addSubview(messageLabel)

        self.incomingXConstraint = bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                                       constant: self.edgeBuffer)
        self.outgoingXConstraint = bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                                        constant: -self.edgeBuffer)

        self.addSubview(self.timestampLabel)
        self.timestampLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true


        self.messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: self.maxMessageWidth).isActive = true
        self.messageLabel.topAnchor.constraint(equalTo: self.topAnchor,
                                                  constant: self.bubbleViewSpacing+self.cellBuffer).isActive = true

        self.bubbleView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor,
                                                 constant: -self.bubbleViewSpacing).isActive = true
        self.bubbleView.topAnchor.constraint(equalTo: messageLabel.topAnchor,
                                             constant: -self.bubbleViewSpacing).isActive = true
        self.bubbleView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor,
                                                  constant: self.bubbleViewSpacing).isActive = true
        self.bubbleView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor,
                                                constant: self.bubbleViewSpacing).isActive = true
        
        self.addSubview(self.reactButton)
        self.reactButton.centerYAnchor.constraint(equalTo: self.timestampLabel.centerYAnchor).isActive = true
        self.reactButton.leadingAnchor.constraint(equalTo: self.timestampLabel.trailingAnchor, constant: 10).isActive = true
    }
    
    override func setupMessage() {
        super.setupMessage()
        guard let message = self.message as? TextMessage else {return}
        self.messageLabel.text = message.text
    }
    
    override func layoutMessage() {
        guard let isOutgoingMessage = isOutgoingMessage else {return}
        super.layoutMessage()
        if isOutgoingMessage {
            self.bubbleView.backgroundColor = UIColor(named: "text_alt")
            self.messageLabel.textColor = UIColor(named: "background_alt")
            self.timestampLabelXConstraint = timestampLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 10)
            self.timestampLabelXConstraint?.isActive = true
        } else {
            self.bubbleView.backgroundColor = UIColor.systemGray
            self.messageLabel.textColor = UIColor(named: "background_alt")
            self.timestampLabelXConstraint = timestampLabel.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -10)
            self.timestampLabelXConstraint?.isActive = true
        }
    }
    
    override func addActions() {
        super.addActions()
        guard let pan = self.panGesture else {return}
        self.bubbleView.addGestureRecognizer(pan)
    }
    
}

