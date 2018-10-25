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
    
    public func getConnectionObjects() -> Array<Connection> {
        let count: Int = self.getConnectionTokens().count
        
        var array: Array<Connection> = []
        
        var i: Int = 0
        while i <= count - 1 {
            do {
                try array.append(self.getTokenAtIndex(i))
            }
            catch {
                // Nothing to do.
            }
            i = i + 1
        }
        return array
    }
    
    public func getTokenAtIndex(_ index: Int) throws -> Connection {
        if (!self.getConnectionTokens()[index].isEmpty) {
            let connection: Connection = Connection()
            
            let rawname: String = self.getConnectionTokens()[index]
            
            connection.setName(String(rawname.split(separator: ":").first!))
            connection.setKey(String(rawname.split(separator: ":").last!))
            return connection
        }
        
        throw SettingsException.ConnectionWithIndexNotFound(index: index)
    }
    
    public func removeTokenAtIndex(_ index: Int) -> Void {
        var connections: Array<String> = self.getConnectionTokens()
        connections.remove(at: index)
        self.setConnectionTokens(connections: connections)
    }
    
    public func setConnectionTokens(connections: Array<String>) -> Void {
        self.defaults.set(connections, forKey: "connections")
    }
    
    public func addConnectionToken(token: String, name: String) -> Void {
        var connections: Array<String> = self.getConnectionTokens()
        let connectionName = name + ":" + token
        
        connections.append(connectionName)
        self.setConnectionTokens(connections: connections)
    }
    
    public func removeAllTokens() -> Void {
        var connections: Array<String> = []
        self.setConnectionTokens(connections: connections)
    }
    
}
