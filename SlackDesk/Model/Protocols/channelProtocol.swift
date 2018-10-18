import Foundation

protocol channelProtocol: baseIdNameModelProtocol {
    func addMessage(_ message: Message) -> Void
    func getMessages() -> [Message]
    func isDirectMessageChannel() -> Bool
    func markAsDirectMessageChannel() -> Void
}
