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

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let collectionViewContentHeight = scrollView.contentSize.height
//        let collectionViewHeight = scrollView.frame.size.height
//        if offsetY >= collectionViewContentHeight - (collectionViewHeight+50) {
//            initialScrollComplete = true
//        }
//        let attributes = self.collectionView.layoutAttributesForItem(at: [0, 0])
//        let rect = collectionView.convert(attributes!.frame, to: collectionView)
//        let oldHeight = rect.height
//
//        if offsetY < collectionViewHeight * leadingScreensForBatching, initialScrollComplete {
//            if !self.fetchingMoreMessages && !endOfMessageListReached {
//                self.beginMessageBatchFetch {
//                    let attributes = self.collectionView.layoutAttributesForItem(at: [0, 0])
//                    let rect = self.collectionView.convert(attributes!.frame, to: self.collectionView)
//                    let newHeight = rect.height
//
//                }
//            }
//        }
//    }

    public func beginMessageBatchFetch() {
        guard let conversation = conversation else {return}
        
        if !endOfMessageListReached {
            let firstPost = self.messages.first?.first
            MessagingManager.shared.fetchMessages(firstMessage: firstPost, onConversation: conversation) { [weak self] oldMessages in
                guard let self = self, let oldMessages = oldMessages else {return}
                
                if oldMessages.count != 0 {
                    let organiser = MessageOrganiser(newMessages: oldMessages, existingMessages: self.messages)
                    guard let messages = organiser.organisePaginatedMessages() else { return }
                    self.messages = messages
                    
                    DispatchQueue.main.async {
                        // Add all messages function?
                        self.collectionView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    self.refreshControl.endRefreshing()
                }
                
            }
        }
    }
    
    @objc public func refresh() {
        beginMessageBatchFetch()
    }
    
}
