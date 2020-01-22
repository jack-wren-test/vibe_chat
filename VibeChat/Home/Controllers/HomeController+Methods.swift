//
//  HomeController+Methods.swift
//  VibeChat
//
//  Created by Jack Smith on 10/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension HomeController {
    
    public func searchBarConfig() {
        self.searchBar.layer.addBorder(edge: .bottom, color: .gray, thickness: 1)
        self.searchBar.delegate = self
    }
    
    public func tableViewConfig() { 
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 80
        self.tableView.keyboardDismissMode = .interactive
    }
    
    public func orderConversationsByLatestMesage(conversations: [String: Conversation]) -> [Conversation] {
        let orderedConversations = conversations.values.sorted { $0.lastMessageTime > $1.lastMessageTime }
        return orderedConversations
    }
    
    public func presentAuthenticationScreen() {
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.searchBar?.resignFirstResponder()
        switch segue.identifier {
        case "ProfileSegue":
            let vc = segue.destination as! UserProfileController
            vc.homeDelegate = self
        case "NewConversationSegue":
            let vc = segue.destination as! NewConversationController
            vc.homeDelegate = self
        case "MessagesSegue":
            let vc = segue.destination as! MessagesController
            if let indexPath = tableView.indexPathForSelectedRow {
                if searching {
                    vc.conversation = searchResults[indexPath.row]
                } else {
                    guard let orderedConvos = orderedConversations else {return}
                    vc.conversation = orderedConvos[indexPath.row]
                }
            }
        default:
            break
        }
    }
    
    public func listenForConversationChanges() {
        CurrentUser.shared.listenToConversations { [weak self] (conversations) in
            guard let self = self else {return}
            conversations.forEach { self.conversationsDict[$0.uid] = $0 }
            self.orderedConversations = self.orderConversationsByLatestMesage(conversations: self.conversationsDict)
            self.tableView.reloadData()
            self.addNoConversationsCoverIfNeeded(orderedConversations: self.orderedConversations)
        }
    }
    
    public func getDictionaryOfConversations(conversations: [Conversation]) -> [String: Conversation] {
        var dict = [String: Conversation]()
        for conversation in conversations {
            dict[conversation.uid] = conversation
        }
        return dict
    }
    
    public func addNoConversationsCoverIfNeeded(orderedConversations: [Conversation]?) {
        var noConversationsCover: NoConversationsCoverView?
        if orderedConversations?.count == 0 || orderedConversations == nil {
            let noConversationsCover = NoConversationsCoverView()
            view.addSubview(noConversationsCover)
            noConversationsCover.constraintsEqual(toView: tableView)
        } else {
            noConversationsCover?.removeFromSuperview()
            noConversationsCover = nil
        }
    }
    
}

