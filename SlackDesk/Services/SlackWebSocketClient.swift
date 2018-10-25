import Foundation
import Starscream
import SwiftyJSON
import RxSwift

// This file might need the most work on reworking.
//
// @todo: I do not like this implementation. Ideally the SlackWebSocketClient should
// not be aware of the Connection model.
//
// I would like the websocket to be able to dispatch events, and have a socket listener
// parse the data to the correct models.
class SlackWebSocketClient: WebSocketDelegate {
    
    public let connection: Connection;
    public let client: SlackClient;
    private var pingTimer:Timer!
    private var socket:WebSocket!
    private var connectTimer:Timer!
    private var actionID:Int = 0
    
    public var isConnected:Variable<Bool> = Variable(false)
    
    init(connection: Connection) {
        self.connection = connection
        self.client = SlackClient(apiKey: self.connection.getKey())
    }
    
    public func startWebSocket() {
        self.client.getRTMconnectionUrl() { rtmUrl, error in
            if (error == nil && !rtmUrl.isEmpty) {
                self.socket = WebSocket(url: URL(string: rtmUrl)!)
                self.socket.delegate = self
                self.socket.connect()
                if self.connectTimer != nil && self.connectTimer.isValid {
                    self.connectTimer.invalidate()
                }
                self.startWebSocketPinger()
            }
            else {
                self.attemptReconnect()
            }
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        self.isConnected.value = true
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.isConnected.value = false
        self.attemptReconnect()
    }
    
    func attemptReconnect() {
        self.pingTimer.invalidate()
        self.connectTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            // @todo: Show message about reconnect attempt.
            self!.startWebSocket()
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        do {
            let type = try JSON(data: text.data(using: .utf8, allowLossyConversion: false)!)
            if let typevalue = type["type"].string {
                switch typevalue {
                case "message":
                    let message: Message = Message()
                    message.setBody(type["text"].stringValue)
                    message.setUserId(type["user"].stringValue)
                    message.setTimeStamp(type["ts"].stringValue)
                    try self.connection.findChannelById(type["channel"].stringValue).addMessage(message)
                    break;
                case "channel_marked", "im_marked":
                    // @todo: Implement.
                    break;
                case "channel_created":
                    // @todo: New channel created.
                    break;
                case "presence_change":
                    // @tood: User changed presence.
                    break;
                default:
                    break;
                }
            }
        } catch {
            // @todo: improve.
            print("Unexpected error: \(error).")
        }
    }
    
    public func sendMessage(message: String, channel: Channel) {
        let data:Dictionary = [
            "id": self.getIncrementedActionId(),
            "type": "message",
            "channel":channel.getId(),
            "text": message
            ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        self.socket.write(string: jsonString!) {
            let messageObject: Message = Message()
            messageObject.setBody(message)
            messageObject.setUserId("You")
            channel.addMessage(messageObject)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        // Nothing to do yet.
    }
    
    private func startWebSocketPinger() {
        self.pingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.pingWebSocket()
        }
    }
    
    private func pingWebSocket() {
        self.socket.write(string: "{\"id\": " + self.getIncrementedActionId() + ", \"type\": \"ping\"}")
    }
    
    private func getIncrementedActionId() -> String {
        self.actionID = self.actionID + 1
        return String(self.actionID)
    }
}

