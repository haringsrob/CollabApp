//
//  SettingsControllerTests.swift
//  SlackDeskTests
//
//  Created by Rob Harings on 12/10/2018.
//  Copyright © 2018 Rob Harings. All rights reserved.
//
import XCTest
@testable import SlackDesk

class SettingsControllerTests: XCTestCase {
    
    private let settingsController: SettingsController = SettingsController()
    
    public func testConnectionSettings() -> Void {
        let settings: Array<String> = ["token-1", "token-2"]
        
        self.settingsController.setConnectionTokens(connections: settings)
        XCTAssertEqual(["token-1", "token-2"], self.settingsController.getConnectionTokens())
        
        self.settingsController.addConnectionToken(token: "token-3")
        XCTAssertEqual(["token-1", "token-2", "token-3"], self.settingsController.getConnectionTokens())
    }
}
