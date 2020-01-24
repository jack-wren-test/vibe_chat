//
//  HomeController+SearchBar.swift
//  VibeChat
//
//  Created by Jack Smith on 22/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension HomeController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let orderedConversations = orderedConversations else {return}
        self.searching = true
        self.searchResults = orderedConversations.filter({ conversation -> Bool in
            let chatterName = conversation.chatter!.name
            return chatterName.prefix(searchText.count) == searchText
        })
        self.homeTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchBar?.resignFirstResponder()
        print(self.searching)
    }
    
}
