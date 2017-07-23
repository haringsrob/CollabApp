//
//  Channel.swift
//  SlackDesk
//
//  Created by Rob Harings on 07/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import ReactiveSwift

class Channel {
    
    public var name:String
    public var id:String
    public var type:String
    public var lastMessageTs:String?
    public var sortWeight:Int

    private var rowId:Int!
    public var unreadCount:MutableProperty<Int> = MutableProperty(0)
    
    private var connection:Connection
    
    var messageDataSource:MessagesDatasource!
    
    init(name: String, id: String, type: String, connection: Connection, sortWeight: Int) {
        self.name = name
        if type == "im" {
            self.name = (connection.users?.findUserForId(id: name).name)!
        }
        self.id = id
        self.type = type
        self.connection = connection
        self.sortWeight = sortWeight
        
        self.messageDataSource = MessagesDatasource(connection: connection, channel: self)
        
        self.unreadCount.signal.observe {channel in
            self.connection.refreshChannel.value = self.getRowId()
        }
    }
    
    public func getName() -> String {
        if self.unreadCount.value > 0 {
            return self.name + " (" + String(self.unreadCount.value) + ")"
        }
        return self.name
    }
    
    public func incrementUnreadCount() {
        self.unreadCount.value = self.unreadCount.value + 1
    }
    
    public func resetUnreadCount() {
        self.unreadCount.value = 0
    }
    
    public func setLastMessageTs(ts: String) {
        self.lastMessageTs = ts
    }
    
    public func setReadMarker() {
        if let lastMessageTs = self.lastMessageTs {
            let connectionDataRequest:DataRequestController = DataRequestController(connection: self.connection, endpoint: self.type + ".mark")
            connectionDataRequest.addRequestParameter(key: "channel", value: self.id)
            connectionDataRequest.addRequestParameter(key: "ts", value: lastMessageTs)
            connectionDataRequest.getResponseAsJson() { responseJSON, error in
            }
        }
    }
    
    public func setRowId(row: Int) {
        self.rowId = row
    }
    
    public func getRowId() -> Int {
        if rowId == nil {
            return 0
        }
        return rowId
    }

    public func getChannelEndpointArgument() -> String {
        switch self.type {
            case "im":
                return "im"
            case "group":
                return "group"
            default:
                return "channel"
        }
    }
}
