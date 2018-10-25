import XCTest
import Mockingjay
import SwiftyJSON
@testable import CollabApp

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
                [
                    "id": "GC3F5A953",
                    "name":"GC3F5A953",
                    "name_normalized": "mpdm-u1--u2--u3",
                ],
                [
                    "id": "secondchannel",
                    "name":"SecondChannel Name",
                    "name_normalized":"SecondChannel Name",
                ]
            ]
        ]
        stub(uri("/api/conversations.list"), json(body))
        
        let expectation = XCTestExpectation(description: "Channels fetched")
        
        let channelController:ChannelController = ChannelController(connection: self.connection)
        channelController.updateChannelList() {response, error in
            expectation.fulfill()
            
            XCTAssertEqual(2, self.connection.getChannels().value.count)
            XCTAssertEqual("u1, u2, u3", self.connection.getChannels().value.first?.getName())
            XCTAssertEqual("GC3F5A953", self.connection.getChannels().value.first?.getId())
            
            XCTAssertEqual("SecondChannel Name", self.connection.getChannels().value.last?.getName())
            XCTAssertEqual("secondchannel", self.connection.getChannels().value.last?.getId())
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    public func testChannelMessages() {
        let channel: Channel = Channel();
        channel.setId("GC3F5A953")
        
        let messagesBody = [
            "messages": [
                [
                    "user": "U012AB3CDE",
                    "text":"I find you punny and would like to smell your nose letter",
                    "ts":"1512085950.000216",
                ],
            ]
        ]
        stub(uri("/api/conversations.history"), json(messagesBody))
        
        let expectation = XCTestExpectation(description: "Messages fetched")
        
        let channelController:ChannelController = ChannelController(connection: self.connection)
        channelController.getHistoryForChannel(channel: channel)  {response, error in
            expectation.fulfill()
            XCTAssertEqual(1, channel.getMessages().value.count)
            XCTAssertEqual("U012AB3CDE", channel.getMessages().value.first?.getUserId())
            XCTAssertEqual("I find you punny and would like to smell your nose letter", channel.getMessages().value.first?.getBody())
            XCTAssertEqual("1512085950.000216", channel.getMessages().value.first?.getTimeStamp())
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}
