import Foundation
import RxSwift

protocol channelProtocol: baseIdNameModelProtocol {
    func addMessage(_ message: Message) -> Void
    func getMessages() -> Variable<[Message]>
    func isDirectMessageChannel() -> Bool
    func markAsDirectMessageChannel() -> Void
}
