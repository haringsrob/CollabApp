import XCTest
@testable import CollabApp

class SettingsControllerTests: XCTestCase {
    
    private let settingsController: SettingsController = SettingsController()
    
    public func testConnectionSettings() -> Void {
        UserDefaults.blankDefaultsWhile {
            XCTAssertEqual([""], self.settingsController.getConnectionTokens())
            
            let settings: Array<String> = ["token-1", "token-2"]
            
            self.settingsController.setConnectionTokens(connections: settings)
            XCTAssertEqual(["token-1", "token-2"], self.settingsController.getConnectionTokens())
            
            self.settingsController.addConnectionToken(token: "token-3")
            XCTAssertEqual(["token-1", "token-2", "token-3"], self.settingsController.getConnectionTokens())
        }
    }
}

// Ensures that the defaults are empty when running the tests.
// @see: http://www.figure.ink/blog/2016/10/15/testing-userdefaults
extension UserDefaults {
    static func blankDefaultsWhile(handler:()->Void){
        let bundle = Bundle.main
        let defs = UserDefaults.standard
        
        guard let name = bundle.bundleIdentifier else {
            fatalError("Couldn't find bundle ID.")
        }
        let old = defs.persistentDomain(forName: name)
        defer {
            defs.setPersistentDomain( old ?? [:], forName: name)
        }
        
        defs.removePersistentDomain(forName: name)
        handler()
    }
}
