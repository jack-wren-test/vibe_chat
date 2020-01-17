//
//  ComeController+TableView.swift
//  VibeChat
//
//  Created by Jack Smith on 10/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

// Extend home controller with UITableView implementations
extension HomeController:   UITableViewDelegate,
                            UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orderedConversations?.count ?? 0
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
        self.performSegue(withIdentifier: "MessagesSegue", sender: self)
    }
    
}
