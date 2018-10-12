import Foundation

class Channel: baseIdNameModel, channelProtocol {
    
    private var messages = [Message]()
    
    public func addMessage(_ message: Message) -> Void {
        self.messages.append(message);
    }
    
    public func getMessages() -> [Message] {
        return messages;
    }
    
}
