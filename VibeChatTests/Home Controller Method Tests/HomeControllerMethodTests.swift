//
//  HomeControllerFunctionTests.swift
//  VibeChatTests
//
//  Created by Jack Smith on 13/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import XCTest
@testable import VibeChat

class HomeControllerMethodTests: XCTestCase {
    
    // MARK:- Properties
    
    var controller: HomeController?
    
    // MARK:- Lifecycle

    override func setUp() {
        controller = HomeController()
    }

    override func tearDown() {
        controller = nil
    }
    
    // MARK:- Test Methods

    func testGetDictionaryOfConversations() {
        guard let controller = controller else {return}
        let dummyConversations = [Conversation(uid: NSUUID().uuidString),
                                  Conversation(uid: NSUUID().uuidString),
                                  Conversation(uid: NSUUID().uuidString),
                                  Conversation(uid: NSUUID().uuidString)]
        
        let dict = controller.getDictionaryOfConversations(conversations: dummyConversations)
        dict.keys.forEach { (key) in
            XCTAssertTrue(key == dict[key]?.uid)
            XCTAssertTrue(dict[key]?.userNames[0] == "Test1")
            XCTAssertTrue(dict[key]?.userNames[1] == "Test2")
        }
    }
    

}
