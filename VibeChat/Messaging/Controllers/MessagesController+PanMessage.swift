//
//  MessagesController+PanMessage.swift
//  VibeChat
//
//  Created by Jack Smith on 29/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension MessagesController: MessageCellDelegate {
    
    func presentReactionsPanel(forCellAtIndexPath: IndexPath) {
        <#code#>
    }
    
    func handleCellPan(forCellAtIndexPath indexPath: IndexPath, pan: UIPanGestureRecognizer) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MessageCell else {return}
        let xTranslation = pan.translation(in: self.view).x
        guard let modifiedTranslation = modifyTranslation(cell: cell, xTranslation: xTranslation) else {return}
        switch pan.state {
        case .began:
            break
        case .changed:
            self.animateViewsWithPan(cell: cell, xTranslation: modifiedTranslation)
        case .ended:
            self.animateSnapToPosition(cell: cell, xTranslation: modifiedTranslation)
        case .cancelled:
            self.animateSnapToPosition(cell: cell, xTranslation: modifiedTranslation)
        default:
            break
        }
    }
    
    public func animateSnapToPosition(cell: MessageCell, xTranslation: CGFloat) {
        guard let isOutgoingMessage = cell.isOutgoingMessage,
              let openConstant = cell.openConstant,
              let closedConstant = cell.closedConstant else {return}
        
        let absTranslation = abs(xTranslation)
        let isOpening = cell.messageRevealStatus == .outgoingOpening || cell.messageRevealStatus == .incomingOpening
        let willSnap = absTranslation > abs(openConstant/2) ? true : false
        
        var finalConstant: CGFloat
        if isOpening {
            finalConstant = willSnap ? openConstant : closedConstant
        } else {
            finalConstant = willSnap ? closedConstant : openConstant
        }
        
        if isOutgoingMessage {
            cell.outgoingXConstraint?.constant = finalConstant
        } else {
            cell.incomingXConstraint?.constant = finalConstant
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            cell.layoutIfNeeded()
        }) { _ in
            cell.currentPosition = finalConstant
        }
    }
    
    private func modifyTranslation(cell: MessageCell, xTranslation: CGFloat) -> CGFloat? {
        var newTranslation: CGFloat
        guard let messageRevealStatus = cell.messageRevealStatus,
              let openConstant = cell.openConstant else {return nil}
        
        if messageRevealStatus == .outgoingOpening || messageRevealStatus == .icomingClosing {
            newTranslation = max(openConstant, min(xTranslation, 0))
        } else {
            newTranslation = min(-openConstant, max(xTranslation, 0))
        }
        
        return newTranslation
    }
    
    public func animateViewsWithPan(cell: MessageCell, xTranslation: CGFloat) {
        guard let isOutgoingMessage = cell.isOutgoingMessage,
              let currentPosition = cell.currentPosition,
              let openConstant = cell.openConstant else {return}
        
        if isOutgoingMessage {
            cell.outgoingXConstraint?.constant = currentPosition + xTranslation
        } else {
            cell.incomingXConstraint?.constant = currentPosition + xTranslation
        }
    }

    
}
