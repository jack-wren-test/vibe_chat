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
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = self.messages[indexPath.section][indexPath.row]
        return self.setupCell(message: message, indexPath: indexPath)
    }
    
    private func setupCell(message: Message, indexPath: IndexPath) -> MessageCell {
        guard let type = message.type else {return MessageCell()}
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: type.reuseId, for: indexPath) as! MessageCell
        cell.message = message
        if let cell = cell as? ImageMessageCell {
            cell.delegate = self
        }
        if let cell = cell as? VideoMessageCell {
            cell.videoView?.delegate = self
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat!
        let message = self.messages[indexPath.section][indexPath.item]
        if let message = message as? TextMessage {
            height = self.estimatedFrameForText(text: message.text!).height+22
        } else if let message = message as? ImageBasedMessage {
            height = 225/message.aspectRatio
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .light)], context: nil)
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages[section].count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseId, for: indexPath) as! DateHeader
        header.dateLabel.date = self.messages[indexPath.section][0].timestamp
        return header
    }
    
}
