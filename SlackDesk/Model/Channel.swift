import Foundation
import RxSwift

class Channel: baseIdNameModel {
    
    static let directMessage = 1
    static let userGroup = 2
    static let lockedChannel = 3
    static let regularChannel = 4

    private var isPrivate: Bool = false;
    private var type: Int = Channel.directMessage
    private var messages:Variable<[Message]> = Variable([])
    public var messagesLoaded:Variable<Bool> = Variable(false)

    func isDirectMessageChannel() -> Bool {
        return self.isPrivate
    }
    
    func markAsDirectMessageChannel() -> Void {
        self.isPrivate = true
    }
    
    public func addMessage(_ message: Message) -> Void {
        self.messages.value.append(message);
    }
    
    public func getMessages() -> Variable<[Message]> {
        return messages;
    }
    
    public func markMessagesLoaded() -> Void {
        self.messagesLoaded.value = true
    }
    
    public func getMessagesLoaded() -> Variable<Bool> {
        return self.messagesLoaded
    }
    
    public func setType(_ type: Int) -> Void {
        self.type = type
    }

    public func getType() -> Int {
        return self.type
    }
}
