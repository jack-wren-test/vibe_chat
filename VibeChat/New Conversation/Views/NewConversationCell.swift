//
//  NewConversationCell.swift
//  VibeChat
//
//  Created by Jack Smith on 20/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class NewConversationCell: UITableViewCell {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK:- Properties
    
    var chatter: User? {
        didSet {
            
            guard let chatter = chatter else {return}
            nameLabel.text = chatter.name
            statusLabel.text = chatter.status ?? ""
            nameLabel.backgroundColor = .clear
            statusLabel.backgroundColor = .clear
            
            chatter.imageFromChacheOrDb { (image) in
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
            }
            
        }
    }
    
    // MARK:- ViewDidLoad

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    // MARK:- Methods

}