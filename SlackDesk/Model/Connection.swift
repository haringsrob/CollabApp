import Foundation

class Connection: ConnectionProtocol {
    
    private var name:String = "";
    private var key:String = "";
    public var channels = [Channel]() {
        didSet {
            print("Var update")
        }
    }
    public var users = [User]()
    
    public func setName(_ name: String) -> Void {
        self.name = name;
    }
    
    public func getName() -> String {
        return self.name;
    }
    
    public func setKey(_ key: String) -> Void {
        self.key = key;
    }
    
    public func getKey() -> String {
        return self.key;
    }
    
    func addChannel(_ channel: Channel) {
        self.channels.append(channel)
    }
    
    func getChannels() -> [Channel] {
        return self.channels
    }
    
    func addUser(_ user: User) {
        self.users.append(user)
    }
    
    func getUsers() -> [User] {
        return self.users
    }
}
