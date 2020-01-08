//
//  ChatterProfileController.swift
//  VibeChat
//
//  Created by Jack Smith on 08/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

class ChatterProfileController: UIViewController {
    
    var chatter: User? {
        didSet {
            guard let user = chatter, let currentUser = CurrentUser.shared.data else {return}
            isCurrentUsersProfile = currentUser.uid == user.uid
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
