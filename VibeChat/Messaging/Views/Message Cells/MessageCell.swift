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
    
    // MARK:- Properties
    
    var incomingXConstraint: NSLayoutConstraint?
    var outgoingXConstraint: NSLayoutConstraint?
    
    // MARK:- Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
