//
//  HomeController+Methods.swift
//  VibeChat
//
//  Created by Jack Smith on 10/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension HomeController {
    
    public func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
    }
    
    public func orderConversationsByLatestMesage(conversations: [String: Conversation]) -> [Conversation] {
        let orderedConversations = conversations.values.sorted { $0.lastMessageTime > $1.lastMessageTime }
        return orderedConversations
    }
    
    public func presentAuthenticationScreen() {
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ProfileSegue":
            let vc = segue.destination as! UserProfileController
            vc.homeDelegate = self
        case "NewConversationSegue":
            let vc = segue.destination as! NewConversationController
            vc.homeDelegate = self
            UsersManager.shared.fetchChatters { (chatters) in
                if let chatters = chatters { vc.chatters = chatters }
            }
        case "MessagesSegue":
            let vc = segue.destination as! MessagesController
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let orderedConvos = orderedConversations else {return}
                vc.conversation = orderedConvos[indexPath.row]
            }
        default:
            break
        }
    }
    
    public func listenForConversationChanges() {
        CurrentUser.shared.listenToConversations { (conversations) in
            conversations.forEach { self.conversationsDict[$0.uid] = $0 }
            self.orderedConversations = self.orderConversationsByLatestMesage(conversations: self.conversationsDict)
            self.tableView.reloadData()
        }
    }
    
    public func getDictionaryOfConversations(conversations: [Conversation]) -> [String: Conversation] {
        var dict = [String: Conversation]()
        for conversation in conversations {
            dict[conversation.uid] = conversation
        }
        return dict
    }
    
}

