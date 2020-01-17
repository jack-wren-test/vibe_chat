//
//  UsersManagerTests.swift
//  VibeChatTests
//
//  Created by Jack Smith on 13/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import XCTest
@testable import VibeChat

class UsersManagerTests: NetworkTest {
    
    // MARK:- Properties
    
    static let testUser = User(uid: "usersManagerTester", name: "usersManagerTester", email: "usersManagerTester@test.com")
    static let testUserPassword = "usersManagerTester"
    
    // MARK:- Lifecycle
    
    override class func setUp() {
        createTestAccount(testUser: testUser, password: testUserPassword)
    }
    
    override class func tearDown() {
        deleteTestAccount(testUser: testUser)
        deleteTestData(testUser: testUser)
    }
    
    // MARK:- Test Methods

    func testUpdateUserData() {
        weak var waitForUploadExpectation = expectation(description: "waitForUploadExpectation")
        UsersManager.shared.updateUserData(forUser: UsersManagerTests.testUser) { (error) in
            XCTAssertNil(error)
            waitForUploadExpectation?.fulfill()
        }
        waitForExpectation(5)
    }
    
    func testToggleIsOnline() {
        weak var waitForIsOnlineToggleExpectation = expectation(description: "waitForIsOnlineToggleExpectation")
        UsersManager.shared.toggleIsOnline(user: UsersManagerTests.self.testUser) { (success) in
            XCTAssertTrue(success)
            waitForIsOnlineToggleExpectation?.fulfill()
        }
        waitForExpectation(5)
    }
    
    func testFetchUserData() {
        weak var waitForFetchUserDataExpectation = expectation(description: "waitForFetchUserDataExpectation")
        UsersManager.shared.fetchUserData(uid: UsersManagerTests.self.testUser.uid) { (user) in
            XCTAssertNotNil(user)
            waitForFetchUserDataExpectation?.fulfill()
        }
        waitForExpectation(5)
    }
    
    func testListenToUserData() {
        weak var waitForListenToUserExpectation = expectation(description: "waitForListenToUserExpectation")
        let _ = UsersManager.shared.listenToUserData(user: UsersManagerTests.self.testUser) { (user) in
            XCTAssertNotNil(user)
            waitForListenToUserExpectation?.fulfill() // Should run another update? To make sure it listens?
        }
        waitForExpectation(5)
    }
    
    func testFetchChatters() {
        weak var waitForFetchChattersExpectation = expectation(description: "waitForFetchChattersExpectation")
        UsersManager.shared.fetchChatters { (users) in
            XCTAssertNotNil(users)
            waitForFetchChattersExpectation?.fulfill()
        }
        waitForExpectation(5)
    }
    
}
