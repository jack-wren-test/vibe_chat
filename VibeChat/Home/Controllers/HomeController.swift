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
    
    var addingConversation = 2
    var loadedFromStoryboard: Bool = false
    var authenticationNeeded: Bool = true
    var chatters = [User]()                         // <- All potential chatters - move to new conversation controller
    var conversations: [String: Conversation]?      // <- All this users conversations
    var orderedConversations: [Conversation]?
//    var orderedKeysForConversations: [String]?
    let reuseIdentifier = "ChatterCell"
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadedFromStoryboard = true
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
        if let orderedConvos = self.orderedConversations {
            let conversationIsRead = orderedConvos[indexPath.row].isReadStatus
            cell.chatter = orderedConvos[indexPath.row].chatter
            cell.isReadStatus = conversationIsRead
        }
        print("Index Path: (\(indexPath.row) \(indexPath.section)) --> \(cell.chatter?.name ?? "")")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.orderedConversations?[indexPath.row].isReadStatus = true
        performSegue(withIdentifier: "MessagesSegue", sender: self)
    }
    
    // MARK:- Methods
    
    fileprivate func orderConversationsByLatestMesage(conversations: [String: Conversation]) -> [Conversation] {
        let orderedConversations = conversations.values.sorted { $0.lastMessageTime > $1.lastMessageTime }
        return orderedConversations
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
                vc.homeDelegate = self
                vc.chatters = chatters
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

// MARK:- Delegate Protocol Methods

extension HomeController: HomeDelegate {
    
    func presentNewChatWindow(conversation: Conversation) {
        let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "MessagesController") as! MessagesController
        vc.conversation = conversation
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateChatters(chatters: [User]) {
        self.chatters = chatters
    }
    
    func updateConversations(conversations: [Conversation]) {

        if self.conversations?.count == nil {
            let dictConversations = getDictionaryOfConversations(conversations: conversations)
            self.orderedConversations = orderConversationsByLatestMesage(conversations:  dictConversations)
            self.conversations = dictConversations
        } else if conversations.count == 1, let currentConvos = self.conversations, currentConvos[conversations[0].uid] == nil {
            addingConversation = 0
            let newConversation = conversations[0]
            newConversation.fetchChatter {
                self.conversations?[newConversation.uid] = newConversation
                self.orderedConversations = self.orderConversationsByLatestMesage(conversations:  self.conversations!)
                if self.tableView.numberOfSections == 0 {
                    self.tableView.insertSections(IndexSet([0]), with: .top)
                } else {
                    if self.orderedConversations?.count != self.tableView.numberOfRows(inSection: 0) {
                        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                    }
                }
            }
        } else if let changedConversation = conversations.first, loadedFromStoryboard {
            if addingConversation < 2 {
                addingConversation += 1
            } else {
                changedConversation.fetchChatter {
                    self.conversations?[changedConversation.uid] = changedConversation
                    self.orderedConversations = self.orderConversationsByLatestMesage(conversations:  self.conversations!)
                    if self.loadedFromStoryboard { self.tableView.reloadData() }
                }
            }
        }
    }
    
    func performLogOut() {
        self.conversations = nil
        self.orderedConversations = nil
        self.tableView.reloadData()
        self.presentAuthenticationScreen()
        CurrentUser.shared.logOut()
    }
}
