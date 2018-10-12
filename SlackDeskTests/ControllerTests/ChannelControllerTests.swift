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
                [
                    "id": "GC3F5A953",
                    "name":"mpdm-tom--info707--yves.sterckx-1",
                ],
                [
                    "id": "secondchannel",
                    "name":"SecondChannel Name",
                ]
            ]
        ]
        stub(everything, json(body))
        
        let expectation = XCTestExpectation(description: "Channels fetched")
        
        let channelController:ChannelController = ChannelController(connection: self.connection)
        channelController.updateChannelList() {response, error in
            expectation.fulfill()
            
            XCTAssertEqual(2, self.connection.getChannels().count)
            XCTAssertEqual("mpdm-tom--info707--yves.sterckx-1", self.connection.getChannels().first?.getName())
            XCTAssertEqual("GC3F5A953", self.connection.getChannels().first?.getId())
            
            XCTAssertEqual("SecondChannel Name", self.connection.getChannels().last?.getName())
            XCTAssertEqual("secondchannel", self.connection.getChannels().last?.getId())
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
        stub(everything, json(messagesBody))
        
        let expectation = XCTestExpectation(description: "Messages fetched")
        
        let channelController:ChannelController = ChannelController(connection: self.connection)
        channelController.getHistoryForChannel(channel: channel)  {response, error in
            expectation.fulfill()
            XCTAssertEqual(1, channel.getMessages().count)
            XCTAssertEqual("U012AB3CDE", channel.getMessages().first?.getUserId())
            XCTAssertEqual("I find you punny and would like to smell your nose letter", channel.getMessages().first?.getBody())
            XCTAssertEqual("1512085950.000216", channel.getMessages().first?.getTimeStamp())
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}
