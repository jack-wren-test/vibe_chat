//
//  MessagesController+CollectionViewDataSource.swift
//  VibeChat
//
//  Created by Jack Smith on 03/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import UIKit

extension MessagesController:   UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.section][indexPath.row]
        switch message {
        case let message as TextMessage where message.type == .textMessage :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: textReuseId, for: indexPath) as! TextMessageCell
            cell.textMessage = message
            return cell
        case let message as ImageMessage where message.type == .imageMessage :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageReuseId, for: indexPath) as! ImageMessageCell
            cell.imageMessage = message
            cell.controllerDelegate = self
            return cell
        case let message as GiphyMessage where message.type == .giphyMessage :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: giphyReuseId, for: indexPath) as! GiphyMessageCell
            cell.giphyMessage = message
            return cell
        case let message as VideoMessage where message.type == .videoMessage :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videoReuseId, for: indexPath) as! VideoMessageCell
            cell.videoMessage = message
            cell.controllerDelegate = self
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat!
        let message = messages[indexPath.section][indexPath.item]
        switch message {
        case let message as TextMessage where message.type == .textMessage:
            if let text = message.text {
                height = estimatedFrameForText(text: text).height+20
            }
        default:
            if let message = message as? ImageBasedMessage {
                height = 200/message.aspectRatio
            }
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .light)], context: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return messages.count
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: <#T##String#>, for: <#T##IndexPath#>)
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let dateLabel = DateHeader()
//        dateLabel.date = messages[section][0].timestamp
//
//        let containerView = UIView()
//        containerView.addSubview(dateLabel)
//        dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
//        dateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//
//        return containerView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
    
    
    
}
