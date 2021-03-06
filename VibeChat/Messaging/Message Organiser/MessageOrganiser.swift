//
//  MessageOrganiser.swift
//  VibeChat
//
//  Created by Jack Smith on 15/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import Foundation

class MessageOrganiser {
    
    // MARK:- Properties
    
    private let calendar = Calendar.current
    
    private var newMessages: [Message]
    private var existingMessages: [[Message]]?
    
    // MARK:- Lifecycle
    
    init(newMessages: [Message], existingMessages: [[Message]]?) {
        self.newMessages = newMessages
        self.existingMessages = existingMessages
    }
    
    // MARK:- Methods
    
    /// Organises the new messages as previous messages brought through during pagination.
    public func organisePaginatedMessages() -> [[Message]]? {
        guard var brokenOutExistingMessages = breakOutExistingMessages() else {return nil}
        brokenOutExistingMessages.append(contentsOf: self.newMessages)
        let organisedMessages = self.sortAndGroupMessages(brokenOutExistingMessages)
        return organisedMessages
    }
    
    private func breakOutExistingMessages() -> [Message]? {
        guard let existingMessages = self.existingMessages else {return nil}
        var brokenOutMessages = [Message]()
        existingMessages.forEach { messageDay in
            brokenOutMessages.append(contentsOf: messageDay)
        }
        return brokenOutMessages
    }
    
    /// Organises new messages and existing messages into 2D array of messages sorted by date and time.
    public func organiseMessages() -> [[Message]]? {
        var organisedMessages: [[Message]]?
        let isFirstTimeLoading = self.existingMessages == nil ? true : false
        
        if isFirstTimeLoading {
            organisedMessages = self.sortAndGroupMessages(newMessages)
        } else if let existingMessages = self.existingMessages {
            organisedMessages = self.appendNewMessagesToExistingMessages(newMessages, existingMessages)
        }
        
        return organisedMessages
    }
    
    /// Appends new messages to the appropriate day of messages within the existing messages array.
    /// - Parameters:
    ///   - newMessages: New messages to append
    ///   - existingMessages: Existing messages to append to
    private func appendNewMessagesToExistingMessages(_ newMessages: [Message],
                                                         _ existingMessages: [[Message]]) -> [[Message]] {
        var fullSetOfMessages: [[Message]] = existingMessages
        if self.isSameDay(newMessages), var todaysMessages = fullSetOfMessages.last  {
            todaysMessages.append(contentsOf: newMessages)
            fullSetOfMessages[fullSetOfMessages.count-1] = todaysMessages
        } else {
            fullSetOfMessages.append(newMessages)
        }
        return fullSetOfMessages
    }
    
    /// Sorts an array of messages into a 2D array of messages organised by day and time.
    /// - Parameter messages: The message array to organise.
    private func sortAndGroupMessages(_ messages: [Message]) -> [[Message]] {
        let dictOfMessagesKeyedByDate = Dictionary(grouping: messages) { (element) -> Date in
            return self.calendar.startOfDay(for: element.timestamp!)
        }
        let sortedDates = dictOfMessagesKeyedByDate.keys.sorted()
        let sortedAndGroupedMessages = groupMessagesByDateAndTime(sortedDates, dictOfMessagesKeyedByDate)
        return sortedAndGroupedMessages
    }
    
    /// Group messages by date and sort by time, earliest  to latest.
    /// - Parameters:
    ///   - sortedDates: Array of dates to organise messages into
    ///   - groupedMessages: Dict of messages keyed by their day of messaging
    private func groupMessagesByDateAndTime(_ sortedDates: [Date],
                                                _ groupedMessages: [Date : [Message]]) -> [[Message]] {
        var sortedAndGroupedMessages = [[Message]]()
        sortedDates.forEach { (key) in
            let messagesForDate = groupedMessages[key]
            let sortedMessages = messagesForDate?.sorted(by: { (message1, message2) -> Bool in
                return message1.timestamp! < message2.timestamp!
            })
            if let sortedMessages = sortedMessages {
                sortedAndGroupedMessages.append(sortedMessages)
            }
        }
        return sortedAndGroupedMessages
    }
    
    /// Compare the date of the new messages arrival (almost always only 1 message).
    /// - Parameters:
    ///   - newMessages: Messages to check the date of
    ///   - calendar: The calendar to check against (use .current)
    private func isSameDay(_ newMessages: [Message]) -> Bool {
        if  let todaysMessages = self.existingMessages?.last,
            let latestMessageTimestamp = todaysMessages.first?.timestamp,
            let thisMessageTimestamp = newMessages.first?.timestamp,
            self.calendar.startOfDay(for: latestMessageTimestamp) == self.calendar.startOfDay(for: thisMessageTimestamp) {
            return true
        }
        return false
    }
}
