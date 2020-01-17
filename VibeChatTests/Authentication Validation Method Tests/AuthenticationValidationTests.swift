//
//  AuthenticationControllerTests.swift
//  VibeChatTests
//
//  Created by Jack Smith on 13/01/2020.
//  Copyright © 2020 Jack Smith. All rights reserved.
//

import XCTest
@testable import VibeChat

class AuthenticationValidationTests: XCTestCase {
    
    // MARK:- Properties
    
    var authenticator: AuthenticateController?
    
    // MARK:- Lifecycle
    
    override func setUp() {
        authenticator = AuthenticateController()
    }
    
    override func tearDown() {
        authenticator = nil
    }
    
    // MARK:- Test Methods

    func testIsPasswordComplex() {
        guard let authenticator = authenticator else {return}
        
        let goodPassword = "Test1234"
        let badPasswords = ["test1234",
                            "Test123",
                            "passwordtest",
                            "passwordtest",
                            "12345678"]
        
        let goodPasswordPass = authenticator.checkPasswordIsComplex(password: goodPassword)
        XCTAssertTrue(goodPasswordPass)
        
        badPasswords.forEach { (badPassword) in
            let badPasswordPass = authenticator.checkPasswordIsComplex(password: badPassword)
            XCTAssertFalse(badPasswordPass)
        }
    }

}
