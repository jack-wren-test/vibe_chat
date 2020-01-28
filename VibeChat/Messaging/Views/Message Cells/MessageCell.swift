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
}

/// Base class for a message cell.
class MessageCell: UICollectionViewCell {
    
    // MARK:- Properties
    
    let timestampLabel = MessageTimeLabel()
    var timestampLabelXConstraint: NSLayoutConstraint?
    
    let maxMessageWidth: CGFloat = 225
    let cellBuffer: CGFloat = 2
    let edgeBuffer: CGFloat = 10
    
    weak var messageCellDelegate: MessageCellDelegate?
    var indexPath: IndexPath?
    
    var panGesture: UIPanGestureRecognizer?
    var blurView: UIVisualEffectView?
 
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
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        self.message = nil
        self.viewHeightAnchor = nil
        self.incomingXConstraint = nil
        self.outgoingXConstraint = nil
    }
    
    // MARK:- Methods
    
    public func addTapGesture() {
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    }
    
    private func setRevealStatus(_ xTranslation: CGFloat) {
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
        let xTranslation = pan.translation(in: self).x
        self.setRevealStatus(xTranslation)
        guard let modifiedTranslation = self.modifyTranslation(xTranslation) else {return}
        
        switch pan.state {
        case .began:
            self.addBlurLayer()
        case .changed:
            self.animateViewsWithPan(modifiedTranslation)
        case .ended:
            self.animateSnapToPosition(modifiedTranslation)
        case .cancelled:
            self.animateSnapToPosition(modifiedTranslation)
        default:
            print("Default pan state case.")
        }
    }
    
    public func animateSnapToPosition(_ translation: CGFloat) {
        guard let isOutgoingMessage = isOutgoingMessage,
              let openConstant = self.openConstant,
              let closedConstant = self.closedConstant else {return}
        
        let absTranslation = abs(translation)
        let isOpening = self.messageRevealStatus == .outgoingOpening || self.messageRevealStatus == .incomingOpening
        let willSnap = absTranslation > 75 ? true : false
        
        var finalBlurViewAlpha: CGFloat
        var finalConstant: CGFloat
        
        if isOpening {
            finalConstant = willSnap ? openConstant : closedConstant
            finalBlurViewAlpha = willSnap ? 1 : 0
        } else {
            finalConstant = willSnap ? closedConstant : openConstant
            finalBlurViewAlpha = willSnap ? 0 : 1
        }
        
        if isOutgoingMessage {
            self.outgoingXConstraint?.constant = finalConstant
        } else {
            self.incomingXConstraint?.constant = finalConstant
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blurView?.alpha = finalBlurViewAlpha
            self.layoutIfNeeded()
        }) { _ in
            self.currentPosition = finalConstant
            if !isOpening { self.blurView?.removeFromSuperview() }
        }
    }
    
    public func animateViewsWithPan(_ translation: CGFloat) {
        guard let isOutgoingMessage = isOutgoingMessage,
              let currentPosition = self.currentPosition else {return}
        
        var blurAlphaValue = abs(translation)/abs(openConstant!)
        blurAlphaValue = blurAlphaValue >= 1 ? 1 : blurAlphaValue
        self.blurView?.alpha = blurAlphaValue
        
        if isOutgoingMessage {
            self.outgoingXConstraint?.constant = currentPosition + translation
        } else {
            self.incomingXConstraint?.constant = currentPosition + translation
        }
    }
    
    private func addBlurLayer() {
        let blur =  UIBlurEffect(style: .dark)
        
        self.blurView = UIVisualEffectView(effect: blur)
        self.superview?.addSubview(blurView!)
        blurView?.alpha = 0
        blurView?.constraintsEqual(toView: self.superview!)
        
        self.superview?.bringSubviewToFront(self)
    }
    
    private func modifyTranslation(_ xTranslation: CGFloat) -> CGFloat? {
        var newTranslation: CGFloat
        guard let messageRevealStatus = self.messageRevealStatus,
              let openConstant = self.openConstant else {return nil}
        
        if messageRevealStatus == .outgoingOpening || messageRevealStatus == .icomingClosing {
            newTranslation = max(openConstant, min(xTranslation, 0))
        } else {
            newTranslation = min(-openConstant, max(xTranslation, 0))
        }
        
        return newTranslation
    }
    
    public func setupMessage() {
        guard let message = message, let date = message.timestamp, let user = CurrentUser.shared.data else {return}
        self.isOutgoingMessage = message.fromUid == user.uid
        self.layoutMessage()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss"
        self.timestampLabel.text = formatter.string(from: date)
        self.addTapGesture()
    }
    
    public func layoutMessage() {
        guard let isOutgoingMessage = isOutgoingMessage else {return}
        
        self.timestampLabel.textAlignment   = isOutgoingMessage ? .right : .left
        self.incomingXConstraint?.isActive  = isOutgoingMessage ? false : true
        self.outgoingXConstraint?.isActive  = isOutgoingMessage ? true : false
        
        self.openConstant       = isOutgoingMessage ? -150 : 150
        self.closedConstant     = isOutgoingMessage ? -10 : 10
        self.currentPosition    = closedConstant
    }
    
    public func updateHeightAnchor(usingAspectRatio aspectRatio: CGFloat) {
        self.viewHeightAnchor = self.heightAnchor.constraint(equalToConstant: self.maxMessageWidth/aspectRatio)
        self.viewHeightAnchor?.priority = UILayoutPriority.init(rawValue: 999)
        self.viewHeightAnchor?.isActive = true
    }
    
}
