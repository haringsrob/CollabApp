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
    
    // This should at one point be taken out.
    private var notificationManager: NotificationManager
    
    public var isConnected:Variable<Bool> = Variable(false)
    
    init(connection: Connection) {
        self.connection = connection
        self.client = SlackClient(apiKey: self.connection.getKey())
        self.notificationManager = NotificationManager(connection: connection)
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
            let json = try JSON(data: text.data(using: .utf8, allowLossyConversion: false)!)
            if let typevalue = json["type"].string {
                switch typevalue {
                case "message":
                    // Get the channel we are acting on.
                    let channel: Channel = try self.connection.findChannelById(json["channel"].stringValue)
                    
                    // Get the subtype of the message.
                    let subtype: String = json["subtype"].stringValue
                    
                    switch subtype {
                    case "message_deleted":
                        channel.deleteMessageByTs(json["previous_message"]["ts"].stringValue)
                        break;
                    case "message_changed":
                        let message: Message = try channel.findMessageByTs(json["previous_message"]["ts"].stringValue)
                        message.setBody(ChannelController.getTextForMessage(json["message"]))
                        channel.hasUpdatedMessage.value = true
                        break;
                    default:
                        // By default we create new messages.
                        let message: Message = Message()
                        
                        message.setBody(ChannelController.getTextForMessage(json))
                        message.setUserId(ChannelController.getUserForMessage(json))
                        message.setTimeStamp(json["ts"].stringValue)
                        
                        // Mark the channel as having unread.
                        channel.hasUnreadMessage.value = true
                        
                        // We only add it if it already is loaded, otherwise, we wait for the history call.
                        if (channel.getMessagesLoaded().value) {
                            channel.addMessage(message)
                        }
                        
                        // Notify.
                        self.notificationManager.showNotificationForMessageAndChannel(message: message, channel: channel)
                        break;
                    }
                    break;
                case "channel_marked", "im_marked":
                    // @todo: Implement.
                    // Currently we are not tracking unreads..
                    break;
                case "channel_created":
                    if json["channel"].null == nil {
                        let channel:Channel = Channel()
                        channel.setName(json["channel"]["name"].string!)
                        channel.setId(json["channel"]["id"].string!)
                        channel.setType(ChannelController.getChannelType(json["channel"]))
                        
                        // Mark the channel as having unread.
                        channel.hasUnreadMessage.value = true
                        
                        self.connection.addChannel(channel)
                        self.notificationManager.showNotificationForNewChannel(channel: channel)
                    }
                    break;
                case "presence_change", "manual_presence_change":
                    // @todo:
                    // This is no longer possible and will require subscriptions. However, this might not
                    // work performant for bigger channels.
                    // Perhaps we could just requery the user list every X minutes.
                    break;
                default:
                    // The rest is not required. It is mostly pings.
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
        self.socket?.write(string: jsonString!) {
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

