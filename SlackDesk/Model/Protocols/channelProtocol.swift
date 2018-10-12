import Foundation

protocol channelProtocol: baseIdNameModelProtocol {
    func addMessage(_ message: Message) -> Void
    func getMessages() -> [Message]
}
