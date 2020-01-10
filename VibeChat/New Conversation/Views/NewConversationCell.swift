//
//  NewConversationCell.swift
//  VibeChat
//
//  Created by Jack Smith on 20/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Cell for use in new conversation view controller.
class NewConversationCell: UITableViewCell {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vibeLabel: UILabel!
    
    // MARK:- Properties
    
    var chatter: User? {
        didSet {
            layoutViews()
        }
    }
    
    // MARK:- Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        chatter = nil
    }
    
    // MARK:- Methods

    private func layoutViews() {
        guard let chatter = chatter else {return}
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
