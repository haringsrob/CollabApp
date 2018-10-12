import XCTest
@testable import SlackDesk

class ConnectionModelTests: XCTestCase {
    
    func testModel() {
        let connection: Connection = Connection()
        
        connection.setKey("A123-SlackConn1_SlackConn1")
        XCTAssertEqual("A123-SlackConn1_SlackConn1", connection.getKey())
        
        connection.setName("SlackConn1")
        XCTAssertEqual("SlackConn1", connection.getName())
    }
    
    func testChannels() {
        let connection: Connection = Connection()
        
        XCTAssertTrue(connection.getChannels().isEmpty);
        
        let channel = Channel()
        connection.addChannel(channel);
        XCTAssertEqual(1, connection.getChannels().count)
        
        connection.addChannel(channel);
        XCTAssertEqual(2, connection.getChannels().count)
    }
    
}
