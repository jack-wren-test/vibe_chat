//
//  NewConversationController.swift
//  VibeChat
//
//  Created by Jack Smith on 17/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit

class NewConversationController: UITableViewController {
    
    // MARK:- Properties
    
    var homeDelegate: HomeDelegate?
    var chatters = [User]() {
        didSet {
            if isViewLoaded { tableView.reloadData() }
        }
    }
    let reuseIdentifier = "ChatterCell"
    
    // MARK:- ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:- TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatters.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! NewConversationCell
        cell.chatter = chatters[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = Conversation(withChatter: chatters[indexPath.row])
        dismiss(animated: true) {
            self.homeDelegate?.presentNewChatWindow(conversation: conversation)
        }
    }
    
}
