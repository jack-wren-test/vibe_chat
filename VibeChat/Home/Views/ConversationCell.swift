//
//  ChatterCellTableViewCell.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

final class ConversationCell: UITableViewCell {

    // MARK:- Outlets

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vibeLabel: UILabel!
    @IBOutlet weak var isReadStatusIndicator: CircularImageView!
    
    // MARK:- Properties
    
    var conversation: Conversation? {
        didSet {
            setupChatterListener()
        }
    }
    
    // MARK:- Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        self.conversation = nil
    }
    
    // MARK:- Methods
    
    fileprivate func setupChatterListener() {
        self.conversation?.listenToChatter(completion: {
            self.configureCellViews()
        })
    }
    
    fileprivate func configureCellViews() {
        guard let conversation = self.conversation else {return}
        guard let chatter = conversation.chatter else {return}
        
        self.profileImageView.layer.borderWidth = chatter.isOnline ? 3 : 0
        self.isReadStatusIndicator.isHidden = conversation.isReadStatus
        
        self.nameLabel.text = chatter.name
        self.vibeLabel.text = chatter.vibe ?? ""
        self.nameLabel.backgroundColor = .clear
        self.vibeLabel.backgroundColor = .clear
        
        chatter.profileImageFromChacheOrDb { [weak self] (image) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }
    }
    
}
