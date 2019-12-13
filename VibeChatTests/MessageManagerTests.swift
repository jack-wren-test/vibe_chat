//
//  MessageManagerTests.swift
//  VibeChatTests
//
//  Created by Jack Smith on 10/12/2019.
//  Copyright © 2019 Jack Smith. All rights reserved.
//

import Foundation

import XCTest
@testable import VibeChat

class MessageManagerTests: XCTestCase {

    let threadId = "dummyThread"
    
    func testFetchAllMessages() {
        
        let waitForFetchAsync = expectation(description: "Async Expectation")
        MessagesManager.shared.fetchAllMessages(forThread: threadId) { (messages) in
            
            // Test messages are sucessfully fetched
            XCTAssertNotNil(messages)
            
            // Test all values of the first message
            guard let messages = messages else {return}
            XCTAssertTrue(type(of: messages[0].timestamp) == Date.self)
            
            waitForFetchAsync.fulfill()
        }
        waitForExpectations(timeout: 1) { (error) in
            guard let error = error else {return}
            print("Spent too long waiting for expectations: \(error.localizedDescription)")
        }
        
    }
    
    func testUploadMessage() {
        
        let waitForUploadAsync = expectation(description: "Async Expectation")
        let message = Message(text: "Test message", toUid: "", fromUid: "", timestamp: Date(), type: "text", threadId: threadId)
        MessagesManager.shared.uploadMessage(message: message) { (success) in
            XCTAssertTrue(success)
            waitForUploadAsync.fulfill()
        }
        waitForExpectations(timeout: 1) { (error) in
            guard let error = error else {return}
            print("Spent too long waiting for expectations: \(error.localizedDescription)")
        }
        
    }
    
    func testListenForMessages() {
        
        let waitForListenAsync = expectation(description: "Async Expectation")
        MessagesManager.shared.listenForMessages(onThread: threadId) { (messages) in
            
            // Test messages are sucessfully fetched
            XCTAssertNotNil(messages)
            
            // Test all values of the latest message
            guard let latestMessage = messages?.last else {return}
            XCTAssertTrue(latestMessage.text == "Test message 2")
            XCTAssertTrue(latestMessage.toUid == "")
            XCTAssertTrue(latestMessage.fromUid == "")
            XCTAssertTrue(latestMessage.type == "text")
            XCTAssertTrue(type(of: latestMessage.timestamp) == Date.self)
            
            waitForListenAsync.fulfill()
        }
        
        let message = Message(text: "Test message 2", toUid: "", fromUid: "", timestamp: Date(), type: "text", threadId: threadId)
        MessagesManager.shared.uploadMessage(message: message) { (success) in
            if success {
                print("Message Uploaded")
            }
        }
        
        waitForExpectations(timeout: 5) { (error) in
            guard let error = error else {return}
            print("Spent too long waiting for expectations: \(error.localizedDescription)")
        }
        
    }

}
