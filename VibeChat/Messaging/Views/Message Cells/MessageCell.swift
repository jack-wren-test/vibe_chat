//
//  MessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

protocol MessageCellDelegate: AnyObject {
    func showHideTimestamp(indexPath: IndexPath)
}

/// Base class for a message cell.
class MessageCell: UICollectionViewCell {
    
    // MARK:- Properties
    
    let timestampLabel = UILabel()
    let maxMessageWidth: CGFloat = 225
    let cellBuffer: CGFloat = 2
    let edgeBuffer: CGFloat = 10
    
    weak var messageCellDelegate: MessageCellDelegate?
    var indexPath: IndexPath?
 
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
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layoutIfNeeded()
        self.addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        self.message = nil
        self.viewHeightAnchor = nil
    }
    
    // MARK:- Methods
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCellTapped))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func handleCellTapped() {
        print("Handle cell tapped!")
        guard let indexPath = indexPath else {return}
        messageCellDelegate?.showHideTimestamp(indexPath: indexPath)
    }
    
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
    
    public func updateHeightAnchor(usingAspectRatio aspectRatio: CGFloat) {
        self.viewHeightAnchor = self.heightAnchor.constraint(equalToConstant: self.maxMessageWidth/aspectRatio)
        self.viewHeightAnchor?.priority = UILayoutPriority.init(rawValue: 999)
        self.viewHeightAnchor?.isActive = true
    }
    
}
