//
//  ViewController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

protocol HomeDelegate {
    func presentNewChatWindow(conversation: Conversation)
    func performLogOut()
}

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        
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
    
    // MARK:- TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedConversations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ConversationCell
        if self.orderedConversations?.count != 0 {
            cell.conversation = self.orderedConversations![indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.orderedConversations?[indexPath.row].isReadStatus = true
        performSegue(withIdentifier: "MessagesSegue", sender: self)
    }
    
    // MARK:- IBActions
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ProfileSegue", sender: self)
    }
    
    @IBAction func newChatButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "NewConversationSegue", sender: self)
    }
    
    fileprivate func getDictionaryOfConversations(conversations: [Conversation]) -> [String: Conversation] {
        var dict = [String: Conversation]()
        for conversation in conversations {
            dict[conversation.uid] = conversation
        }
        return dict
    }
    
    
}

extension HomeController {
    
    fileprivate func orderConversationsByLatestMesage(conversations: [String: Conversation]) -> [Conversation] {
        let orderedConversations = conversations.values.sorted { $0.lastMessageTime > $1.lastMessageTime }
        return orderedConversations
    }
    
    fileprivate func presentAuthenticationScreen() {
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSegue" {
            if let vc = segue.destination as? UserProfileController {
                vc.homeDelegate = self
            }
        }
        if segue.identifier == "NewConversationSegue" {
            if let vc = segue.destination as? NewConversationController {
                vc.homeDelegate = self
                UsersManager.shared.fetchChatters { (chatters) in
                    if let chatters = chatters {
                        vc.chatters = chatters
                    }
                }
            }
        } else if segue.identifier == "MessagesSegue" {
            if let vc = segue.destination as? MessagesController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    guard let orderedConvos = orderedConversations else {return}
                    vc.conversation = orderedConvos[indexPath.row]
                }
            }
        }
    }
    
    fileprivate func listenForConversationChanges() {
        CurrentUser.shared.listenToConversations { (conversations) in
            conversations.forEach { self.conversationsDict[$0.uid] = $0 }
            self.orderedConversations = self.orderConversationsByLatestMesage(conversations: self.conversationsDict)
            self.tableView.reloadData()
        }
    }
    
}

// MARK:- Delegate Protocol Methods

extension HomeController: HomeDelegate {
    
    func presentNewChatWindow(conversation: Conversation) {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "MessagesController") as! MessagesController
        vc.conversation = conversation
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func performLogOut() {
        CurrentUser.shared.logOut { (success) in
            if success {
                print("Succesfully logged out...")
                self.presentAuthenticationScreen()
            } else {
                print("Error logging out...")
            }
        }
    }
}
