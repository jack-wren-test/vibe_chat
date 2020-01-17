//
//  ChatterProfileController.swift
//  VibeChat
//
//  Created by Jack Smith on 08/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

/// Controller for chatter profile view.
class ChatterProfileController: UIViewController {
    
    // MARK:- IBOutlets
    
    @IBOutlet public weak var profileImageView: CircularImageView!
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet public weak var vibeLabel: UILabel!
    
    // MARK:- Properties
    
    var chatter: User?
    
    // MARK:- Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
    }
    
    deinit {
        print("Chatter profile controller deinitialized")
    }
    
    // MARK:- Methods
    
    private func configureViews() {
        self.profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        if let chatter = chatter {
            self.profileImageView.image = chatter.profileImage
            self.nameLabel.text = chatter.name
            self.vibeLabel.text = chatter.vibe
        }
    }

}
