//
//  ViewController.swift
//  VibeChat
//
//  Created by Jack Smith on 04/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

protocol HomeDelegate {
    func presentNewChatWindow(chatter: User)
    func updateChatters(chatters: [User])
    func updateConversations(conversations: [Conversation])
    func performLogOut()
}

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var newChatButton: UIButton!
    
    
    // MARK:- Properties
    
    var authenticationNeeded: Bool = true
    var chatters = [User]()                 // <- All potential chatters - move to new conversation controller
    var conversations: [String: Conversation]?      // <- All this users conversations
    var orderedKeysForConversations: [String]?
    let reuseIdentifier = "ChatterCell"
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if authenticationNeeded {
            presentAuthenticationScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK:- TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ChatterCellTableViewCell
        if let orderedKeys = orderedKeysForConversations {
            let threadIsRead = conversations?[orderedKeys[indexPath.row]]?.isReadStatus
            cell.chatter = conversations?[orderedKeys[indexPath.row]]?.chatter
            cell.isReadStatus = threadIsRead
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let orderedKeys = orderedKeysForConversations else {return}
        conversations?[orderedKeys[indexPath.row]]?.isReadStatus = true
        performSegue(withIdentifier: "MessagesSegue", sender: self)
    }
    
    // MARK:- Methods
    
    fileprivate func orderConversationKeysByLatestMesage(conversations: [String: Conversation]) -> [String] {
        let orderedConversations = conversations.values.sorted { $0.lastMessageTime > $1.lastMessageTime }
        var orderedKeys = [String]()
        for conversation in orderedConversations {
            orderedKeys.append(conversation.threadUid)
        }
        return orderedKeys
    }
    
    fileprivate func presentAuthenticationScreen() {
        chatters = []
        authenticationNeeded = !authenticationNeeded
        performSegue(withIdentifier: "AuthenticateSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // REFACTOR INTO SWITCH
        
        if segue.identifier == "AuthenticateSegue" {
            if let vc = segue.destination as? AuthenticationController {
                vc.homeDelegate = self
            }
        }
        if segue.identifier == "ProfileSegue" {
            if let vc = segue.destination as? ProfileController {
                vc.homeDelegate = self
            }
        }
        if segue.identifier == "NewConversationSegue" {
            print("Preparing for new conversation segue")
            if let vc = segue.destination as? NewConversationController {
                print("Preparing for new conversation segue")
                vc.homeDelegate = self
                vc.chatters = chatters
            }
        } else if segue.identifier == "MessagesSegue" {
            if let vc = segue.destination as? MessagesController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    guard let orderedKeys = orderedKeysForConversations else {return}
                    vc.chatter = self.conversations?[orderedKeys[indexPath.row]]?.chatter
                }
            }
        }
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
            dict[conversation.threadUid] = conversation
        }
        return dict
    }
    
    
}

// MARK:- Delegate Protocol Methods

extension HomeController: HomeDelegate {
    func presentNewChatWindow(chatter: User) {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "MessagesController") as! MessagesController
        vc.chatter = chatter
        navigationController?.pushViewController(vc, animated: true)
    }
    func updateChatters(chatters: [User]) {
        self.chatters = chatters
    }
    func updateConversations(conversations: [Conversation]) {
        if self.conversations?.count == nil {
            let dictConversations = getDictionaryOfConversations(conversations: conversations)
            let orderedKeys = orderConversationKeysByLatestMesage(conversations:  dictConversations)
            self.conversations = dictConversations
            self.orderedKeysForConversations = orderedKeys
        } else {
            let dictConversations = getDictionaryOfConversations(conversations: conversations)
            for key in dictConversations.keys {
                self.conversations?[key] = dictConversations[key]
            }
            let orderedKeys = orderConversationKeysByLatestMesage(conversations:  self.conversations!)
            self.orderedKeysForConversations = orderedKeys
        }
    }
    func performLogOut() {
        self.presentAuthenticationScreen()
        CurrentUser.shared.logOut()
    }
}
