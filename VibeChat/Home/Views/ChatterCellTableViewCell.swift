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
    @IBOutlet weak var isReadStatusIndicator: CircularImageView!
    
    // MARK:- Properties
    
    var isReadStatus: Bool? {
        didSet {
            guard let isRead = isReadStatus else {return}
            isReadStatusIndicator.isHidden = isRead
        }
    }
    var chatter: User? {
        didSet {
            guard let chatter = chatter else {return}
            profileImageView.layer.borderWidth = chatter.isOnline ? 3 : 0
            nameLabel.text = chatter.name
            statusLabel.text = chatter.status ?? ""
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
    
}

@IBDesignable
class CircularImageView: UIImageView {

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

}
