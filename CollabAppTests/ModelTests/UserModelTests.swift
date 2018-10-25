import XCTest
@testable import CollabApp

class UserModelTests: XCTestCase {

    func testModel() {
        let user: User = User()

        user.setId("A123")
        XCTAssertEqual("A123", user.getId())

        user.setName("Slack")
        XCTAssertEqual("Slack", user.getName())
    }

}
