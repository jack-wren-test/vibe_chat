//
//  MessagesController+CollectionViewDataSource.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension MessagesController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dateLabel = DateHeader()
        dateLabel.date = messages[section][0].timestamp
        
        let containerView = UIView()
        containerView.addSubview(dateLabel)
        dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        return containerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.section][indexPath.row]
        switch message {
        case let message as TextMessage where message.type == .textMessage :
            let cell = tableView.dequeueReusableCell(withIdentifier: textReuseId) as! TextMessageCell
            cell.textMessage = message
            return cell
        case let message as ImageMessage where message.type == .imageMessage :
            let cell = tableView.dequeueReusableCell(withIdentifier: imageReuseId) as! ImageMessageCell
            cell.imageMessage = message
            cell.controllerDelegate = self
            return cell
        case let message as GiphyMessage where message.type == .giphyMessage :
            let cell = tableView.dequeueReusableCell(withIdentifier: giphyReuseId) as! GiphyMessageCell
            cell.giphyMessage = message
            return cell
        case let message as VideoMessage where message.type == .videoMessage :
            let cell = tableView.dequeueReusableCell(withIdentifier: videoReuseId) as! VideoMessageCell
            cell.videoMessage = message
            cell.controllerDelegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
}
