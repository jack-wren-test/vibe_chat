//
//  ViewController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Protocol for delegating tasks to the HomeController.
protocol HomeDelegate {
    func presentNewChatWindow(conversation: Conversation)
    func performLogOut()
}

/// Controller for controlling the home view.
class HomeController: UIViewController {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var newChatButton: UIButton!
    
    // MARK:- Properties
    
    var isNewUser = false
    var conversationsDict: [String: Conversation] = [:]
    var orderedConversations: [Conversation]?
    
    let reuseIdentifier = "ChatterCell"
    
    // MARK:- lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        tableViewConfig()
        listenForConversationChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        print("Is new user: \(isNewUser)")
        if isNewUser {
            performSegue(withIdentifier: "ProfileSegue", sender: self)
            isNewUser = !isNewUser
        }
    }
    
    deinit {
        print("home controller deinitialized")
    }
    
    // MARK:- IBActions
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ProfileSegue", sender: self)
    }
    
    @IBAction func newChatButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "NewConversationSegue", sender: self)
    }
    
}
