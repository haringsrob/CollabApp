//
//  MessagesDatasource.swift
//  SlackDesk
//
//  Created by Rob Harings on 07/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import SwiftyJSON
import ReactiveSwift

class messagesStoreCollection {
    let messages = MutableProperty([Message]())
}

class MessagesDatasource: NSObject, NSTableViewDataSource, NSTableViewDelegate  {
    
    public let messageStore:messagesStoreCollection = messagesStoreCollection()
    
    private var messageCollection:[Message] = [Message]()
    
    private var connection:Connection
    private var channel:Channel
    
    init(connection: Connection, channel: Channel) {
        self.connection = connection
        self.channel = channel
        
        super.init()
    }
    
    public func loadAllMessages() {
        if self.messageStore.messages.value.isEmpty {
            let connectionDataRequest:DataRequestController = DataRequestController(connection: self.connection, endpoint: self.channel.type + ".history")
            connectionDataRequest.addRequestParameter(key: "channel", value: self.channel.id)
            connectionDataRequest.getResponseAsJson() { responseJSON, error in
                for (_, message) in (responseJSON?["messages"])! {
                    if (self.messageHasUserOrBot(message: message) && self.messageHasText(message: message)) {
                        let messageObject:Message = Message(
                            message: self.getMessageTextForMessage(message: message),
                            userId: self.getUserForMessage(message: message),
                            ts: message["ts"].string!,
                            connection: self.connection
                        )
                        
                        if self.channel.lastMessageTs == nil {
                            self.channel.lastMessageTs = message["ts"].string!
                        }
                        
                        self.insertMessageAtStartOfList(messageObject: messageObject)
                    }
                }
                self.messageStore.messages.value.insert(contentsOf: self.messageCollection, at: 0)
            }
        }
    }
    
    private func messageHasUserOrBot(message: JSON) -> Bool {
        if (message["bot_id"].null == nil) {
            return true
        }
        if (message["user"].null == nil) {
            return true
        }
        return false
    }
    
    
    private func messageHasText(message: JSON) -> Bool {
        if (message["text"].null == nil) {
            return true
        }
        return false
    }
    
    private func getUserForMessage(message: JSON) -> String {
        if (message["bot_id"].null == nil) {
            return message["bot_id"].string!
        }
        return message["user"].string!
    }

    
    private func getMessageTextForMessage(message: JSON) -> String {
        return message["text"].string!
    }
    
    public func insertMessageAtStartOfList(messageObject: Message) {
        self.messageCollection.insert(messageObject, at: 0)
    }

    // Datasource
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.messageStore.messages.value.count
    }
    
    // Delegate
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return self.messageStore.messages.value[row].getRowSize()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return self.messageStore.messages.value[row].getView()
    }
    
}
