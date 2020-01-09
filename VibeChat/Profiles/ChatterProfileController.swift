//
//  ChatterProfileController.swift
//  VibeChat
//
//  Created by Jack Smith on 08/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

class ChatterProfileController: UIViewController {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vibeLabel: UILabel!
    
    
    // MARK:- Properties
    
    var chatter: User?
    
    // MARK:- Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews() 
    }
    
    // MARK:- Methods
    
    fileprivate func configureViews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        if let chatter = chatter {
            profileImageView.image = chatter.profileImage
            nameLabel.text = chatter.name
            vibeLabel.text = chatter.vibe
        }
    }

}
