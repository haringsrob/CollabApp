import XCTest
import Mockingjay
import SwiftyJSON
@testable import SlackDesk

class ChannelControllerTests: XCTestCase {

    private var connection:Connection!
    
    public override func setUp() {
        self.connection = Connection()
        self.connection.setName("ConnectionName")
        self.connection.setKey("ConnectionApiKey")
    }
    
    public func testClassInitialization() {
        let body = [
            "channels": [
                "id": "GC3F5A953",
                "name":"mpdm-tom--info707--yves.sterckx-1",
            ],
            ]
        stub(everything, json(body))
        
        let expectation = XCTestExpectation(description: "Channels fetched")
        
        let channelController:ChannelController = ChannelController(connection: self.connection)
        channelController.updateChannelList() {response, error in
            expectation.fulfill()
            
            XCTAssertEqual(1, self.connection.getChannels().count)
            XCTAssertEqual("mpdm-tom--info707--yves.sterckx-1", self.connection.getChannels().first?.getName())
            XCTAssertEqual("GC3F5A953", self.connection.getChannels().first?.getId())
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}
