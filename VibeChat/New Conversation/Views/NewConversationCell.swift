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
            self.layoutViews()
        }
    }
    
    // MARK:- Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        self.chatter = nil
    }
    
    // MARK:- Methods

    private func layoutViews() {
        guard let chatter = chatter else {return}
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
