//
//  ChatterCellTableViewCell.swift
//  VibeChat
//
//  Created by Jack Smith on 05/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class ChatterCellTableViewCell: UITableViewCell {

    // MARK:- Outlets

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK:- Properties
    
    var user : User? {
        didSet {
            guard let user = user else {return}
            nameLabel.text = user.name
            statusLabel.text = user.status ?? ""
            user.imageFromChacheOrDb { (image) in
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
    
}
