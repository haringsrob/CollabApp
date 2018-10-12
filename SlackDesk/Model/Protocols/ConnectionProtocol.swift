import Foundation

protocol ConnectionProtocol {
    func setName(_ name: String) -> Void
    func getName() -> String
    func setKey(_ key: String) -> Void
    func getKey() -> String
    func addChannel(_ channel: Channel) -> Void
    func getChannels() -> [Channel]
}
