import XCTest
@testable import SlackDesk

class MessageModelTests: XCTestCase {

    func testModel() {
        let message: Message = Message()

        message.setBody("test")
        XCTAssertEqual("test", message.getBody())

        message.setChannelId("123")
        XCTAssertEqual("123", message.getChannelId())

        message.setMessageId("1234")
        XCTAssertEqual("1234", message.getMessageID())

        message.setUserId("FA113")
        XCTAssertEqual("FA113", message.getUserId())

        message.setTimeStamp("0001234")
        XCTAssertEqual("0001234", message.getTimeStamp())
    }

}
