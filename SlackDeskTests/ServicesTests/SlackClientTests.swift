import XCTest
import Mockingjay
import SwiftyJSON
@testable import SlackDesk

class SlackClientTests: XCTestCase {
    
    private var client:SlackClient = SlackClient(apiKey: "apiKey");
    
    func testApiKeyConfig() -> Void {
        client.setEndpoint("http://test.be")
        XCTAssertEqual(client.endpoint, "http://test.be")
    }
    
    func testConversationList() -> Void {
        let body = [
            "channels": [
                "id": "GC3F5A953",
                "name":"mpdm-tom--info707--yves.sterckx-1",
            ],
        ]
        stub(uri("/api/conversations.list"), json(body))
        
        let expectation = XCTestExpectation(description: "Channels fetched")
        
        self.client.conversationsList() { response, error in
            XCTAssertNotNil(response, "No data was downloaded.")
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFailingRequest() -> Void {
        stub(everything, http(404))
        
        let expectation = XCTestExpectation(description: "Channels not fetched")
        
        self.client.conversationsList() { response, error in
            XCTAssertNotNil(error, "Data was downloaded")
            XCTAssertTrue(response.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}
