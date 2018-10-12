import XCTest
@testable import SlackDesk

class ChannelModelTests: XCTestCase {
    
    func testModel() {
        let channel: Channel = Channel()
        
        channel.setId("A123")
        XCTAssertEqual("A123", channel.getId())
        
        channel.setName("Slack")
        XCTAssertEqual("Slack", channel.getName())
    }
    
    func testMessagesInChannel() {
        let channel: Channel = Channel()
        
        XCTAssertTrue(channel.getMessages().isEmpty);
        
        let message = Message()
        channel.addMessage(message);
        XCTAssertEqual(1, channel.getMessages().count)
        
        channel.addMessage(message);
        XCTAssertEqual(2, channel.getMessages().count)
    }
    
}
