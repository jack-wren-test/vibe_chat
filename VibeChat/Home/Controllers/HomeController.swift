//
//  ViewController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Protocol for delegating tasks to the HomeController.
protocol HomeDelegate: AnyObject {
    func presentNewWindow(conversation: Conversation)
    func performLogOut()
}

/// Controller for controlling the home view.
class HomeController: UIViewController {
    
    // MARK:- IBOutlets
    
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet public weak var profileButton: UIButton!
    @IBOutlet public weak var newChatButton: UIButton!
    @IBOutlet public weak var searchBar: UISearchBar!
    
    // MARK:- Properties
    
    var isNewUser: Bool?
    var conversationsDict: [String: Conversation] = [:]
    var orderedConversations: [Conversation]?
    
    var searching = false
    var searchResults = [Conversation]()
    let reuseIdentifier = "ChatterCell"
    
    // MARK:- lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tableViewConfig()
        self.searchBarConfig()
        self.listenForConversationChanges()
        self.registerForKeyboardWillHide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let isNewUser = self.isNewUser else {return}
        if isNewUser {
            performSegue(withIdentifier: "ProfileSegue", sender: self)
            self.isNewUser = !isNewUser
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        self.searchBar.text = ""
        self.searching = false
        self.tableView.reloadData()
    }
    
    // MARK:- IBActions
    
    @IBAction private func profileButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ProfileSegue", sender: self)
    }
    
    @IBAction private func newChatButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "NewConversationSegue", sender: self)
    }
    
}
