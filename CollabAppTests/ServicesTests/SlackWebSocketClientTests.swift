import XCTest
import Mockingjay
import SwiftyJSON
@testable import CollabApp

class SlackWebSocketClientTests: XCTestCase {
    
    public func testBasicWebsocketBehaviour() -> Void {
        let connection: Connection = Connection()
        connection.setKey("testKey")
        
        let body = ["url": "http://127.0.0.1:8080"]
        stub(uri("/api/rtm.connect"), json(body))

        let _: SlackWebSocketClient = SlackWebSocketClient(connection: connection)
        
        // @todo: How to test this?
    }
    
}
