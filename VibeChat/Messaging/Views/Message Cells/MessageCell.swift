//
//  MessageCell.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    // MARK:- Properties
    
    var incomingXConstraint: NSLayoutConstraint?
    var outgoingXConstraint: NSLayoutConstraint?
    
    // MARK:- Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func layoutMessage(_ isOutgoingMessage: Bool) {
        
        if isOutgoingMessage {
            incomingXConstraint?.isActive = false
            outgoingXConstraint?.isActive = true
        } else {
            outgoingXConstraint?.isActive = false
            incomingXConstraint?.isActive = true
        }
        
    }
    
}
