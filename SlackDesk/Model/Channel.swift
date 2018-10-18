import Foundation
import RxSwift

class Channel: baseIdNameModel, channelProtocol {
    
    private var isPrivate: Bool = false;
    private var messages:Variable<[Message]> = Variable([])
    
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
    
}
