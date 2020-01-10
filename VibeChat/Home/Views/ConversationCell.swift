//
//  ChatterCellTableViewCell.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {

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
        conversation = nil
    }
    
    // MARK:- Methods
    
    fileprivate func setupChatterListener() {
        conversation?.listenToChatter(completion: {
            self.configureCellViews()
        })
    }
    
    fileprivate func configureCellViews() {
        guard let conversation = conversation else {return}
        guard let chatter = conversation.chatter else {return}
        
        profileImageView.layer.borderWidth = chatter.isOnline ? 3 : 0
        isReadStatusIndicator.isHidden = conversation.isReadStatus
        
        nameLabel.text = chatter.name
        vibeLabel.text = chatter.vibe ?? ""
        nameLabel.backgroundColor = .clear
        vibeLabel.backgroundColor = .clear
        
        chatter.profileImageFromChacheOrDb { (image) in
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }
    }
    
}
