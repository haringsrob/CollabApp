import XCTest
import Mockingjay
import SwiftyJSON
@testable import SlackDesk

class UserListControllerTests: XCTestCase {
    
    private var connection:Connection!
    
    public override func setUp() {
        self.connection = Connection()
        self.connection.setName("ConnectionName")
        self.connection.setKey("ConnectionApiKey")
    }
    
    public func testClassInitialization() {
        let body = [
            "members": [
                [
                    "id": "123",
                    "name":"Tarzan",
                ],
                [
                    "id": "987",
                    "name":"Jane",
                ]
            ]
        ]
        stub(everything, json(body))
        
        let expectation = XCTestExpectation(description: "Users fetched")
        
        let userListController:UserListController = UserListController(connection: self.connection)
        userListController.updateUserList() {response, error in
            expectation.fulfill()
            
            XCTAssertEqual(2, self.connection.getUsers().count)
            XCTAssertEqual("Tarzan", self.connection.getUsers().first?.getName())
            XCTAssertEqual("123", self.connection.getUsers().first?.getId())
            
            XCTAssertEqual("Jane", self.connection.getUsers().last?.getName())
            XCTAssertEqual("987", self.connection.getUsers().last?.getId())
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}
