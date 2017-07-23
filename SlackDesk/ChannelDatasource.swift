//
//  ChannelCollection.swift
//  SlackDesk
//
//  Created by Rob Harings on 07/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Observable
import ReactiveSwift
import ReactiveCocoa

class ChannelDatasource: NSObject, NSTableViewDataSource, NSTableViewDelegate  {

    private var connection:Connection
    
    init(connection: Connection) {
        self.connection = connection
        super.init()
        self.loadAllChannelData()
    }
    
    private func loadAllChannelData() {
        self.loadPublicChannels()
        self.loadDirectChannels()
        self.loadGroupChannels()
    }
    
    private func loadPublicChannels() {
        self.connection.channelSetupDispatchGroup.enter()
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self.connection, endpoint: "channels.list")
        connectionDataRequest.getResponseAsJson() { responseJSON, error in
            for (_, channel) in (responseJSON?["channels"])! {
                if channel["is_member"].bool! {
                    self.addChannelAndLoadMessages(channelData: channel, type: "channels", index: "name", sortWeight: 2)
                }
                else {
                    self.addChannelAndLoadMessages(channelData: channel, type: "channels", index: "name", sortWeight: 5)
                }
            }
            self.connection.channelSetupDispatchGroup.leave()
        }
    }
    
    private func loadDirectChannels() {
        self.connection.channelSetupDispatchGroup.enter()
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self.connection, endpoint: "im.list")
        connectionDataRequest.getResponseAsJson() { responseJSON, error in
            for (_, channel) in (responseJSON?["ims"])! {
                self.addChannelAndLoadMessages(channelData: channel, type: "im", index: "user", sortWeight: 3)
            }
            self.connection.channelSetupDispatchGroup.leave()
        }
    }
    
    private func loadGroupChannels() {
        self.connection.channelSetupDispatchGroup.enter()
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self.connection, endpoint: "groups.list")
        connectionDataRequest.getResponseAsJson() { responseJSON, error in
            for (_, channel) in (responseJSON?["groups"])! {
                var a:String?
                if (channel["name"].string?.hasPrefix("mpdm"))! {
                    for (_,subJson):(String, JSON) in (channel["members"]) {
                        let user:User = (self.connection.users?.findUserForId(id: subJson.string!))!
                        if a == nil {
                            a = user.name
                        }
                        else {
                            a = a! + ", " + user.name
                        }
                    }
                }
                if a != nil {
                    self.addChannelAndLoadMessages(channelData: channel, type: "groups", index: "name", alternativeName: a, sortWeight: 4)
                }
                else {
                    self.addChannelAndLoadMessages(channelData: channel, type: "groups", index: "name", sortWeight: 1)
                }
            }
            self.connection.channelSetupDispatchGroup.leave()
        }
    }
    
    private func addChannelAndLoadMessages(channelData: JSON, type: String, index: String, alternativeName: String? = nil, sortWeight: Int) {
        let channel:Channel
        if alternativeName == nil {
            channel = Channel(name: channelData[index].string!, id: (channelData["id"].string)!, type: type, connection: connection, sortWeight: sortWeight)
        }
        else {
            channel = Channel(name: alternativeName!, id: (channelData["id"].string)!, type: type, connection: connection, sortWeight: sortWeight)
        }
        self.connection.addChannel(channel: channel)
    }

    public func sortChannels() {
        self.connection.channelStore.channels.value.sort() {
            $1.sortWeight > $0.sortWeight
        }
    }
    
    public func initializeActiveChannelObservableToFirstChannel() {
        self.connection.setActiveChannel(channel: self.connection.channelStore.channels.value.first!)
    }

    public func findChannelForId(id: String) -> Channel? {
        if let channel = self.connection.channelStore.channels.value.first(where: { $0.id == id }) {
            return channel
        }
        return nil
    }

    // Datasource
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.connection.channelStore.channels.value.count
    }
    
    // Delegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: NSTableCellView?
        let channelItem:Channel = self.connection.channelStore.channels.value[row]
        channelItem.setRowId(row: row)
        
        var identifier:String
        
        switch channelItem.type {
        case "im":
            identifier = "DirectCell"
        case "groups":
            identifier = "GroupCell"
        default:
            identifier = "PublicCell"
        }
        
        view = tableView.make(withIdentifier: identifier, owner: self) as? NSTableCellView
        if let textField = view?.textField {
            textField.stringValue = String(describing: channelItem.getName())
        }
        return view
    }
    
}
