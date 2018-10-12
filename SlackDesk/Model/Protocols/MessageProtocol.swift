import Foundation

protocol MessageProtocol {
    func setBody(_ body: String) -> Void
    func getBody() -> String
    func setChannelId(_ channelId: String) -> Void
    func getChannelId() -> String
    func setMessageId(_ messageId: String) -> Void
    func getMessageID() -> String
    func setTimeStamp(_ timeStamp: String) -> Void
    func getTimeStamp() -> String
    func setUserId(_ userId: String) -> Void
    func getUserId() -> String

}
