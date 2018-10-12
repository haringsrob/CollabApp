import Foundation
import Starscream
import SwiftyJSON

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
    
    init(connection: Connection) {
        self.connection = connection
        self.client = SlackClient(apiKey: self.connection.getKey())
    }
    
    public func startWebSocket() {
        self.client.getRTMconnectionUrl() { rtmUrl, error in
            if (error != nil) {
                self.socket = WebSocket(url: URL(string: rtmUrl)!)
                self.socket.delegate = self
                self.socket.connect()
                if self.connectTimer != nil && self.connectTimer.isValid {
                    self.connectTimer.invalidate()
                }
                self.startWebSocketPinger()
            }
            // @todo: Handle error.
            // It should show an error to the user with more details.
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        // @todo: Mark user online.
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.pingTimer.invalidate()
        self.connectTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            // @todo: Show message about reconnect attempt.
            self!.startWebSocket()
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let json = JSON(text)
        if let dataType = json["type"].string {
            switch dataType {
            case "message":
                // @todo: implement New message.
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

