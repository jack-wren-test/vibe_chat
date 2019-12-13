//
//  AuthenticationController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class AuthenticationController: UIViewController {
    
    // MARK:- Properties
    
    var homeDelegate: HomeDelegate?
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:- Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AuthenticationController
        destination.homeDelegate = homeDelegate
    }
}
