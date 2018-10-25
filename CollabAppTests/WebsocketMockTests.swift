//
//  SlackDeskV2Tests.swift
//  SlackDeskV2Tests
//
//  Created by Rob Harings on 10/10/2018.
//  Copyright © 2018 Rob Harings. All rights reserved.
//

import XCTest
import Starscream

class WebsocketMockTests: XCTestCase, WebSocketDelegate {
    
    var socket: WebSocket!

    func testMockFunctions() {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:8080")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
        sleep(1)
        XCTAssertTrue(socket.isConnected)
        
        socket.disconnect()
        sleep(1)
        XCTAssertFalse(socket.isConnected)
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Todo")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Todo")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Todo")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Todo")
    }


}
