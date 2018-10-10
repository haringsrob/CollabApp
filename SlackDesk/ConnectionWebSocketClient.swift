//
//  ConnectionWebSocketClient.swift
//  SlackDesk
//
//  Created by Rob Harings on 15/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Foundation
import Starscream
import Observable
import SwiftyJSON

class ConnectionWebSocketClient: WebSocketDelegate {
    
    var connection:Connection
    var socket:WebSocket!
    var pingTimer:Timer!
    var actionID:Int = 0
    
    var connectTimer:Timer!
    
    init(connection: Connection) {
        self.connection = connection
    }
    
    public func startWebSocket() {
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self.connection, endpoint: "rtm.connect")
        connectionDataRequest.getResponseAsJson() { responseJSON, error in
            if responseJSON != nil {
                let webSocketUrl = (responseJSON?["url"].string)!
                
                self.socket = WebSocket(url: URL(string: webSocketUrl)!)
                self.socket.delegate = self
                self.socket.connect()
                if self.connectTimer != nil && self.connectTimer.isValid {
                    self.connectTimer.invalidate()
                    self.connection.markUserActive()
                }
                self.startWebSocketPinger()
            }
        }
    }
    
    private func startWebSocketPinger() {
        self.pingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.pingWebSocket()
        }
    }
    
    func pingWebSocket() {
        self.socket.write(string: "{\"id\": " + self.getIncrementedActionId() + ", \"type\": \"ping\"}")
    }
    
    func websocketDidConnect(socket: WebSocket) {
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        self.pingTimer.invalidate()
        self.connectTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.attemptReconnectToWebSocket()
        }
    }
    
    func attemptReconnectToWebSocket() {
        self.startWebSocket()
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let json = JSON(data: text.data(using: .utf8, allowLossyConversion: false)!)
        if let dataType = json["type"].string {
            switch dataType {
                case "message":
                    if let channel:Channel = self.connection.channels!.findChannelForId(id: json["channel"].string!) {
                        channel.incrementUnreadCount()
                        var message:Message!
                        
                        if !self.messageTSisPresentInChannel(ts: json["ts"].string!, channel: channel) {
                            if json["user"].string != nil {
                                message = Message(message: MessageBuilderHelpers.getTextForMessage(JsonMessage: json), userId: json["user"].string!, ts: json["ts"].string!, connection: self.connection)
                            }
                            else if json["bot_id"].string != nil {
                                message = Message(message: json["text"].string!, userId: json["bot_id"].string!, ts: json["ts"].string!, connection: self.connection)
                            }
                        }
                        if message != nil {
                            
                            
                            // Notify.
                            let notification = NSUserNotification()
                            notification.title = "New message in " + channel.getName()
                            notification.informativeText = message.getTextView()
                            notification.soundName = NSUserNotificationDefaultSoundName
                            
                            NSUserNotificationCenter.default.deliver(notification)
                        }
                        
                        // Only add the message if it is populated.
                        if !channel.messageDataSource.messageStore.messages.value.isEmpty {
                            if (message != nil) {
                                channel.messageDataSource.messageStore.messages.value.append(message)
                            }
                        }
                    }
                break
            case "channel_marked",
                 "im_marked":
                // Mark channel count.
                if json["channel"].string != nil {
                    let channel:Channel = self.connection.channels!.findChannelForId(id: json["channel"].string!)!
                    channel.resetUnreadCount()
                }
                break
            case "channel_created":
                if json["channel"].null == nil {
                    let channel:Channel = Channel(name: json["channel"]["name"].string!, id: json["channel"]["id"].string!, type: "channels", connection: self.connection, sortWeight: 5)
                    self.connection.channelStore.channels.value.append(channel)
                }
                break
            case "presence_change":
                if json["presence"].null == nil {
                    self.connection.users?.findUserForId(id: json["user"].string!).presence = json["presence"].string!
                    self.connection.refreshUsers.value = true
                }
                break
            default:
                    if dataType != "pong" {
                    }
                break
            }
        }
    }
    
    private func messageTSisPresentInChannel(ts: String, channel: Channel) -> Bool {
        if channel.messageDataSource.messageStore.messages.value.first(where: { $0.ts == ts }) == nil {
            return false
        }
        return true
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        
    }
    
    public func sendMessage(message: String, channel: Channel) {
        self.socket.write(string: "{\"id\": " + self.getIncrementedActionId() + ", \"type\": \"message\", \"channel\": \"" + channel.id + "\", \"text\": \"" + message + "\"}") {
            channel.messageDataSource.messageStore.messages.value.append(Message(message: message, userId: self.connection.getUserId(), ts: "a", connection: self.connection))
        }
    }
    
    private func getIncrementedActionId() -> String {
        self.actionID = self.actionID + 1
        return String(self.actionID)
    }

}
