//
//  MessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

enum MessageRevealStatus: String {
    
    // MARK:- Cases
    
    case outgoingOpening
    case outgoingClosing
    case incomingOpening
    case icomingClosing
    
    // MARK:- Methods
    
    public func printString() {
        print(self.rawValue)
    }
    
}

protocol MessageCellDelegate: AnyObject {
    func handleCellPan(forCellAtIndexPath: IndexPath, pan: UIPanGestureRecognizer)
    func presentReactionsPanel(forCellAtIndexPath: IndexPath)
}

/// Base class for a message cell.
class MessageCell: UICollectionViewCell {
    
    // MARK:- Properties
    
    let timestampLabel = MessageTimeLabel()
    let reactButton = ReactButton()
    var timestampLabelXConstraint: NSLayoutConstraint?
    
    let maxMessageWidth: CGFloat = 225
    let cellBuffer: CGFloat = 2
    let edgeBuffer: CGFloat = 10
    
    weak var messageCellDelegate: MessageCellDelegate?
    var indexPath: IndexPath?
    
    var panGesture: UIPanGestureRecognizer?
 
    var isOutgoingMessage: Bool?
    var messageRevealStatus: MessageRevealStatus?
    var openConstant: CGFloat?
    var closedConstant: CGFloat?
    var currentPosition: CGFloat?
    
    var incomingXConstraint: NSLayoutConstraint?
    var outgoingXConstraint: NSLayoutConstraint?
    var viewHeightAnchor: NSLayoutConstraint?
    
    var message: Message? {
        didSet {
            self.setupMessage()
        }
    }
    
    // MARK:- Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        self.indexPath = nil
        self.message = nil
        self.viewHeightAnchor = nil
        self.incomingXConstraint = nil
        self.outgoingXConstraint = nil
    }
    
    // MARK:- Methods
    
    public func addActions() {
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.reactButton.addTarget(self, action: #selector(handleReactButtonPressed), for: .touchUpInside)
    }
    
    @objc
    private func handleReactButtonPressed() {
        self.closeMessage {
            guard let indexPath = self.indexPath else {return}
            self.messageCellDelegate?.presentReactionsPanel(forCellAtIndexPath: indexPath)
        }
    }
    
    private func closeMessage(completion: @escaping ()->Void) {
        guard let isOutgoingMessage = self.isOutgoingMessage,
              let closedConstant = closedConstant else {return}
        
        if isOutgoingMessage {
            self.outgoingXConstraint?.constant = closedConstant
        } else {
            self.incomingXConstraint?.constant = closedConstant
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        }) { _ in
            self.currentPosition = closedConstant
            completion()
        }
    }
    
    private func setRevealStatus() {
        guard let isOutgoingMessage = isOutgoingMessage else {return}
        let isOpening = self.currentPosition == self.closedConstant ? true : false
        if isOutgoingMessage && isOpening {
            self.messageRevealStatus = .outgoingOpening
        } else if isOutgoingMessage && !isOpening {
            self.messageRevealStatus = .outgoingClosing
        } else if !isOutgoingMessage && isOpening {
            self.messageRevealStatus = .incomingOpening
        } else {
            self.messageRevealStatus = .icomingClosing
        }
    }
    
    @objc private func handlePan(pan: UIPanGestureRecognizer) {
        guard let indexPath = self.indexPath else {return}
        self.setRevealStatus()
        messageCellDelegate?.handleCellPan(forCellAtIndexPath: indexPath, pan: pan)
    }
    
    public func setupMessage() {
        guard let message = message, let date = message.timestamp, let user = CurrentUser.shared.data else {return}
        self.isOutgoingMessage = message.fromUid == user.uid
        self.layoutMessage()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        self.timestampLabel.text = formatter.string(from: date)
        self.addActions()
    }
    
    public func layoutMessage() {
        guard let isOutgoingMessage = isOutgoingMessage else {return}
        
        self.timestampLabel.textAlignment   = isOutgoingMessage ? .right : .left
        self.incomingXConstraint?.isActive  = isOutgoingMessage ? false : true
        self.outgoingXConstraint?.isActive  = isOutgoingMessage ? true : false
        
        self.openConstant       = isOutgoingMessage ? -100 : 100
        self.closedConstant     = isOutgoingMessage ? -10 : 10
        self.currentPosition    = closedConstant
    }
    
    public func updateHeightAnchor(usingAspectRatio aspectRatio: CGFloat) {
        self.viewHeightAnchor = self.heightAnchor.constraint(equalToConstant: self.maxMessageWidth/aspectRatio)
        self.viewHeightAnchor?.priority = UILayoutPriority.init(rawValue: 999)
        self.viewHeightAnchor?.isActive = true
    }
    
}
