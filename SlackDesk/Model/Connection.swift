import Foundation
import RxSwift

class Connection {
    
    private var name:String = "";
    private var key:String = "";
    public var channels:Variable<[Channel]> = Variable([])
    public var users:Variable<[User]> = Variable([])
    
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
        self.channels.value.append(channel)
    }
    
    func getChannels() -> Variable<[Channel]> {
        return self.channels
    }
    
    func addUser(_ user: User) {
        self.users.value.append(user)
    }
    
    func getUsers() -> Variable<[User]> {
        return self.users
    }
    
    func findChannelById(_ id: String) throws -> Channel {
        guard let channel = channels.value.first(where: { $0.getId() == id }) else {
            throw ChannelException.ChannelWithIdNotFound(id: id)
        }
        
        return channel
    }
    
    func findUserById(_ id: String) throws -> User {
        guard let user = users.value.first(where: { $0.getId() == id }) else {
            throw ChannelException.userWithIdNotFound(id: id)
        }
        
        return user
    }
}
