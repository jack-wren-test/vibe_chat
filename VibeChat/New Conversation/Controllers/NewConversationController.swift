//
//  NewConversationController.swift
//  VibeChat
//
//  Created by Jack Smith on 17/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

/// Controller for new conversation view.
class NewConversationController: UITableViewController {
    
    // MARK:- Properties
    
    weak var homeDelegate: HomeDelegate?
    private(set) var chatters: [User]?
    private let reuseIdentifier = "ChatterCell"
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchChatters()
    }
    
    deinit {
        print("New conversation controller deinitialized")
    }
    
    // MARK:- TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfRows = chatters?.count {
            return numberOfRows
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! NewConversationCell
        cell.chatter = chatters?[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatter = chatters?[indexPath.row] else {return}
        let conversation = Conversation(withChatter: chatter)
        dismiss(animated: true) {
            self.homeDelegate?.presentNewWindow(conversation: conversation)
        }
    }
    
    // MARK:- Methods
    
    private func fetchChatters() {
        UsersManager.shared.fetchChatters { [weak self] (chatters) in
            guard let self = self, let chatters = chatters else {return}
            self.chatters = chatters
            self.tableView.reloadData()
        }
    }
    
}
