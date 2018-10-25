import Foundation

class SettingsController {
    
    private var defaults: UserDefaults;
    
    init() {
        self.defaults = UserDefaults.standard
    }
    
    public func getConnectionTokens()-> Array<String> {
        if (self.defaults.object(forKey: "connections") != nil) {
            return self.defaults.object(forKey: "connections") as! Array<String>
        }
        return [""]
    }
    
    public func setConnectionTokens(connections: Array<String>) -> Void {
        self.defaults.set(connections, forKey: "connections")
    }
    
    public func addConnectionToken(token: String) -> Void {
        var connections: Array<String> = self.getConnectionTokens();
        connections.append(token)
        self.setConnectionTokens(connections: connections)
    }
    
}
