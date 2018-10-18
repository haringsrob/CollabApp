import Foundation

class Channel: baseIdNameModel, channelProtocol {
    
    private var isPrivate: Bool = false;
    private var messages = [Message]()
    
    func isDirectMessageChannel() -> Bool {
        return self.isPrivate
    }
    
    func markAsDirectMessageChannel() -> Void {
        self.isPrivate = true
    }
    
    public func addMessage(_ message: Message) -> Void {
        self.messages.append(message);
    }
    
    public func getMessages() -> [Message] {
        return messages;
    }
    
}
