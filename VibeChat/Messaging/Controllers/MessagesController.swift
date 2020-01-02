//
//  MessagesController.swift
//  VibeChat
//
//  Created by Jack Smith on 09/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import UIKit
import GiphyUISDK
import GiphyCoreSDK
import FirebaseFirestore
import MobileCoreServices
import AVFoundation

protocol messagesControllerDelegate {
    func imageMessageTapped(_ imageView: UIImageView)
}

class MessagesController:   UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource {
    
    // MARK:- IBOutlets
    
    @IBOutlet weak var chatterNameLabel: UILabel!
    @IBOutlet weak var chatterProfileImageView: CircularImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: AuthenticationTextField!
    @IBOutlet weak var textEntryBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var specialMessageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var specialMessageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBarWidthAnchor: NSLayoutConstraint!
    
    // MARK:- Properties
    
    let textReuseId = "textMessageCell"
    let imageReuseId = "imageMessageCell"
    let videoReuseId = "videoMessageCell"
    let giphyReuseId = "giphyMessageCell"
    
    var messages = [[Message]]()
    var conversationListener: ListenerRegistration?
    var conversationStatusListener: ListenerRegistration?
    var conversation: Conversation?
    
    var startingImageView: UIImageView?
    var imageStartingFrame: CGRect?
    var backgroundView: UIView?
    
    // MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GiphyUISDK.configure(apiKey: "vXS5bLeyzx4cOUgU9RVheieQLWXmVRoY")
        
        tableViewConfig()
        setupMessageListener()
        setupConverstationStatusListener()
        
        guard let chatter = conversation?.chatter else {return}
        chatterProfileImageView.layer.borderWidth = chatter.isOnline ? 2 : 0
        chatterProfileImageView.image = chatter.profileImage
        chatterNameLabel.text = chatter.name
        
        registerForKeyboardWillShow()
        registerForKeyboardWillHide()
        setupTapToDismissKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        conversationListener?.remove()
        conversationStatusListener?.remove()
    }
    
    deinit {
        print("Messages controller deinitialised")
    }
    
    // MARK:- Methods
    
    fileprivate func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: textReuseId)
        tableView.register(ImageMessageCell.self, forCellReuseIdentifier: imageReuseId)
        tableView.register(GiphyMessageCell.self, forCellReuseIdentifier: giphyReuseId)
    }
    
    fileprivate func scrollToBottomOfMessages() {
        if messages.count > 0 {
            let row = messages[messages.count-1].count-1
            let section = messages.count-1
            tableView.scrollToRow(at: IndexPath(row: row, section: section), at: .bottom, animated: true)
        }
    }
    
    fileprivate func animateAddNewMessage(_ isNewSection: Bool) {
        let row = messages[messages.count-1].count-1
        let section = messages.count-1
        if isNewSection {
            tableView.insertSections([section], with: .fade)
        } else {
            tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .fade)
        }
    }
    
    fileprivate func setupConverstationStatusListener() {
        conversationStatusListener = UserMessagesManager.shared.listenForConversationChanges(conversaion: conversation!, completion: { (conversation) in
            if let conversation = conversation, self.isViewLoaded {
                conversation.fetchChatter{
                    guard let isOnline = conversation.chatter?.isOnline else {return}
                    self.chatterProfileImageView.layer.borderWidth = isOnline ? 2 : 0
                }
            }
        })
    }
    
    fileprivate func setupMessageListener() {
        guard let conversation = conversation else {return}
        conversationListener = MessagingManager.shared.listenForMessages(onConversation: conversation) { (messages) in
            guard let messages = messages else {return}
            let daysOfMessagesCount = self.messages.count
            if let sortedMessages = self.groupMessagesByDate(messages) {
                self.messages = sortedMessages
                if self.isViewLoaded {
                    self.tableView.reloadData()
                    self.scrollToBottomOfMessages()
                    if conversation.hasDbCounterpart {self.conversation!.isReadStatus = true}
                    self.conversation!.isReadStatus = true
                }
            } else {
                if self.isViewLoaded {
                    let isSection = self.messages.count != daysOfMessagesCount
                    self.animateAddNewMessage(isSection)
                    self.scrollToBottomOfMessages()
                    if conversation.hasDbCounterpart {self.conversation!.isReadStatus = true}
                }
            }
        }
    }
    
    fileprivate func groupMessagesByDate(_ messages: [Message]) -> [[Message]]? {
        let calendar = Calendar.current
        if self.messages.count == 0 {
            var sortedAndGroupedMessages = [[Message]]()
            let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
                return calendar.startOfDay(for: element.timestamp!)
            }
            let sortedKeys = groupedMessages.keys.sorted()
            sortedKeys.forEach { (key) in
                let messagesForDate = groupedMessages[key]
                let sortedMessages = messagesForDate?.sorted(by: { (message1, message2) -> Bool in
                    return message1.timestamp! < message2.timestamp!
                })
                sortedAndGroupedMessages.append(sortedMessages ?? [])
            }
            return sortedAndGroupedMessages
        } else {
            if var todaysMessages = self.messages.last,
                let latestMessageTimestamp = self.messages.last?.first?.timestamp,
                let thisMessageTimestamp = messages.first?.timestamp,
                calendar.startOfDay(for: latestMessageTimestamp) == calendar.startOfDay(for: thisMessageTimestamp) {
                todaysMessages.append(contentsOf: messages)
                self.messages.removeLast()
                self.messages.append(todaysMessages)
            } else {
                self.messages.append(messages)
            }
        }
        return nil
    }
    
    override func animateViewWithKeyboard(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.5) {
                self.specialMessageLeadingConstraint.constant = 0
                self.specialMessageViewWidthConstraint.constant = 0
                self.textEntryBottomConstraint.constant = -keyboardHeight
                self.view.layoutIfNeeded()
            }
            scrollToBottomOfMessages()
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            self.specialMessageLeadingConstraint.constant = 10
            self.specialMessageViewWidthConstraint.constant = 110
            self.textEntryBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        keyboardIsHidden = true
    }
    
    // MARK:- TableViewDataSource
    
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
        if let imageMessage = messages[indexPath.section][indexPath.row] as? ImageMessage {
            let cell = tableView.dequeueReusableCell(withIdentifier: imageReuseId) as! ImageMessageCell
            cell.imageMessage = imageMessage
            cell.controllerDelegate = self
            return cell
        } else if let videoMessage = messages[indexPath.section][indexPath.row] as? VideoMessage {
            let cell = VideoMessageCell(style: .default, reuseIdentifier: videoReuseId)
            cell.videoMessage = videoMessage
            cell.controllerDelegate = self
            return cell
        } else if let giphyMessage = messages[indexPath.section][indexPath.row] as? GiphyMessage {
            let cell = GiphyMessageCell(style: .default, reuseIdentifier: giphyReuseId)
            cell.giphyMessage = giphyMessage
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: textReuseId) as! TextMessageCell
            cell.message = messages[indexPath.section][indexPath.row]
            return cell
        }
    }
    
    // MARK:- @IBActions
    
    @IBAction func giphyButtonPressed(_ sender: Any) {
        let giphy = GiphyViewController()
        giphy.delegate = self
        if self.traitCollection.userInterfaceStyle == .dark {
            giphy.theme = .dark
        }
        present(giphy, animated: true)
    }
    
    
    @IBAction func imageMessageButtonPressed(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true)
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func vibeButtonPressed(_ sender: UIButton) {
        print("Vibe button pressed")
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let conversation = conversation else {return}
        if messageTextField.text != "" {
            if let text = messageTextField.text, let toUid = conversation.chatter?.uid, let fromUid = CurrentUser.shared.data?.uid {
                messageTextField.text = ""
                UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
                    let message = Message(text: text, toUid: toUid, fromUid: fromUid, timestamp: Date(), threadId: conversation.uid)
                    UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                        MessagingManager.shared.uploadMessage(message: message)
                    }
                }
            }
        }
    }
    
}

extension MessagesController: UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            handleVideoSelected(videoUrl)
        } else {
            handleImageSelected(info)
        }
        dismiss(animated: true)
        
    }
    
    fileprivate func handleImageSelected(_ info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let image = selectedImageFromPicker {
            StorageManager.shared.uploadImageMessage(image: image) { (url) in
                if let url = url {
                    self.sendImageMessageWithUrl(url: url)
                }
            }
        }
    }
    
    fileprivate func sendImageMessageWithUrl(url: URL) {
        guard let conversation = conversation else {return}
        UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
            let message = ImageMessage(imageUrl: url, toUid: conversation.chatter!.uid, fromUid: CurrentUser.shared.data!.uid, timestamp: Date(), threadId: conversation.uid)
            UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                MessagingManager.shared.uploadMessage(message: message)
            }
        }
    }
    
    fileprivate func handleVideoSelected(_ videoFileUrl: URL) {
        do {
            let videoData = try Data(contentsOf: videoFileUrl)
            let uploadTask = StorageManager.shared.uploadVideoMessage(video: videoData) { (uploadedVideoUrl) in
                if let uploadedVideoUrl = uploadedVideoUrl {
                    if let thumbnailImage = self.thumbnailImageForVideoUrl(videoFileUrl: videoFileUrl) {
                        StorageManager.shared.uploadVideoThumbnail(image: thumbnailImage) { (url) in
                            if let thumbnailImageUrl = url {
                                let aspectRatio = thumbnailImage.size.width / thumbnailImage.size.height
                                self.sendVideoMessageWithUrl(videoUrl: uploadedVideoUrl,
                                                             thumbnailUrl: thumbnailImageUrl,
                                                             aspectRatio: aspectRatio)
                            }
                        }
                    }
                }
            }
            var progressBarPercentage: Float = 0
            uploadTask.observe(.progress) { [unowned self] (snapshot) in
                if (snapshot.progress?.completedUnitCount) != nil {
                    if progressBarPercentage < 75 {
                        progressBarPercentage += 15
                        self.updateProgressBar(percentageComplete: progressBarPercentage)
                    }
                }
            }
            uploadTask.observe(.success) { [unowned self] (snapshot) in
                self.updateProgressBar(percentageComplete: 100)
            }
        } catch {
            print("Error loading video to data object: \(error.localizedDescription)")
        }
    }
    
    fileprivate func thumbnailImageForVideoUrl(videoFileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoFileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage).rotate(radians: .pi/2)
        } catch {
            print("Error getting thumbnail image: \(error.localizedDescription)")
        }
        return nil
    }
    
    fileprivate func sendVideoMessageWithUrl(videoUrl: URL, thumbnailUrl: URL, aspectRatio: CGFloat) {
        guard let conversation = conversation else {return}
        UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
            let message = VideoMessage(videoUrl: videoUrl, thumbnailImageUrl: thumbnailUrl, aspectRatio: aspectRatio, toUid: conversation.chatter!.uid, fromUid: CurrentUser.shared.data!.uid, timestamp: Date(), threadId: conversation.uid)
            UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                MessagingManager.shared.uploadMessage(message: message)
            }
        }
    }
    
    fileprivate func updateProgressBar(percentageComplete: Float) {
        let phoneWidth = view.frame.width
        let newWidth = CGFloat(percentageComplete/100)*phoneWidth
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.progressBarWidthAnchor.constant = newWidth
            self.view.layoutIfNeeded()
        }) { (_) in
            if percentageComplete == 100 {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.progressBarWidthAnchor.constant = newWidth
                    self.view.layoutIfNeeded()
                }) {(_) in self.progressBarWidthAnchor.constant = 0}
            }
        }
    }
    
}

extension MessagesController: GiphyDelegate {
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        sendGiphyMessage(withGiphId: media.id) {
            giphyViewController.dismiss(animated: true)
        }
    }
    
    func didDismiss(controller: GiphyViewController?) {}
    
    fileprivate func sendGiphyMessage(withGiphId: String, completion: @escaping ()->()) {
        guard let conversation = conversation else {return}
        UserMessagesManager.shared.createConversationIfNeeded(conversation: conversation) { (_) in
            let message = GiphyMessage(giphId: withGiphId, toUid: conversation.chatter!.uid, fromUid: CurrentUser.shared.data!.uid, timestamp: Date(), threadId: conversation.uid)
            UserMessagesManager.shared.updateConversationStatus(conversation: conversation, userIsRead: true, chatterIsRead: false, withNewMessageTime: Date()) {
                MessagingManager.shared.uploadMessage(message: message) {
                    completion()
                }
            }
        }
    }
    
}

extension MessagesController: messagesControllerDelegate {
    
    func imageMessageTapped(_ imageView: UIImageView) {
        startingImageView = imageView
        startingImageView?.isHidden = true
        imageStartingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: imageStartingFrame!)
        zoomingImageView.image = imageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        if let keywindow = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) {
            backgroundView = UIView(frame: keywindow.frame)
            backgroundView!.backgroundColor = UIColor(named: "background")
            backgroundView!.alpha = 0
            keywindow.addSubview(backgroundView!)
            keywindow.addSubview(zoomingImageView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView!.alpha = 1
                let height = self.imageStartingFrame!.height / self.imageStartingFrame!.width * keywindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keywindow.frame.width, height: height)
                zoomingImageView.center = keywindow.center
            }, completion: nil)
        }
    }
    
    @objc fileprivate func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 10
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.imageStartingFrame!
                self.backgroundView?.alpha = 0
            }) { (completed: Bool) in
                self.startingImageView?.isHidden = false
                zoomOutImageView.removeFromSuperview()
                self.backgroundView = nil
            }
        }
    }
    
}
