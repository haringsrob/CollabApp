//
//  Connection.swift
//  SlackDesk
//
//  Created by Rob Harings on 06/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReactiveSwift
import ReactiveCocoa
import Result

class usersStoreCollection {
    let users = MutableProperty([User]())
}

class channelStoreCollection {
    let channels = MutableProperty([Channel]())
}

class Connection {
    
    public let userStore:usersStoreCollection = usersStoreCollection()
    public let channelStore:channelStoreCollection = channelStoreCollection()

    public var users:UsersDatasource?
    public var channels:ChannelDatasource?
    
    public var view:NSView?
    
    private var index:Int!
    
    private var activeChannel:MutableProperty<Channel>!
    
    public var refreshChannel:MutableProperty<Int> = MutableProperty(0)
    public var refreshUsers:MutableProperty<Bool> = MutableProperty(false)

    private var userId:String?
    private var token:String
    
    public var usersSetupDispatchGroup = DispatchGroup()
    public var channelSetupDispatchGroup:DispatchGroup!
    
    private var name:MutableProperty<String>
    
    private var dispatchGroup:DispatchGroup
    
    private var isvalid:Bool = false
    
    init(name: String, token: String, dispatchGroup: DispatchGroup, initDispatchGroup: DispatchGroup) {
        initDispatchGroup.enter()
        self.dispatchGroup = dispatchGroup
        self.name = MutableProperty(name)
        self.token = token
        self.checkIfValidConnection(initDispatchGroup: initDispatchGroup)
    }
    
    public func isValidConnection() -> Bool {
        return self.isvalid
    }
    
    private func checkIfValidConnection(initDispatchGroup: DispatchGroup) {
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self, endpoint: "auth.test")
        connectionDataRequest.getResponseAsJson() { responseJSON, error in
            self.isvalid = !((responseJSON?["user_id"].null) != nil)
            initDispatchGroup.leave()
        }
    }
    
    public func initConnection() {
        self.dispatchGroup.enter()
        self.getBaseUserInfo()
        self.markUserActive()
        self.UpdateDataForConnection()
        
        self.users = UsersDatasource(connection: self)
        
        self.usersSetupDispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
            self.channelSetupDispatchGroup = DispatchGroup()
            self.channels = ChannelDatasource(connection: self)
            
            self.channelSetupDispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
                self.channels?.initializeActiveChannelObservableToFirstChannel()
                self.dispatchGroup.leave()
            }
        }
    }
    
    private func getBaseUserInfo() {
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self, endpoint: "auth.test")
        connectionDataRequest.getResponseAsJson() { responseJSON, error in
            self.userId = (responseJSON?["user_id"].string)!
        }
    }
    
    public func markUserActive() {
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self, endpoint: "users.setActive")
        connectionDataRequest.getResponseAsJson() { responseJSON, error in }
    }

    public func setTabViewItem(tabViewItem: NSView) {
        self.view = tabViewItem
    }
    
    public func UpdateDataForConnection() {
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self, endpoint: "team.info")
        connectionDataRequest.getResponseAsJson() { responseJSON, error in
            self.name.value = (responseJSON?["team"]["name"].string)!
        }
    }
    
    public func getUserId() -> String {
        return self.userId!
    }
    
    public func getName() -> MutableProperty<String> {
        return self.name
    }
    
    public func getToken() -> String {
        return self.token
    }
    
    public func getActiveChannelProperty() -> MutableProperty<Channel> {
        return self.activeChannel
    }
    
    public func getActiveChannel() -> Channel {
        return self.activeChannel.value
    }
    
    public func setActiveChannel(channel: Channel) {
        if self.activeChannel == nil {
            self.activeChannel = MutableProperty(channel)
        }
        self.activeChannel.value = channel
        
        self.activeChannel.value.setReadMarker()
    }
    
    public func addChannel(channel: Channel) {
        self.channelStore.channels.value.append(channel)
    }
    
    public func setTabIndex(count: Int) {
        self.index = count
    }
    
    public func getTabIndex() -> Int {
        return self.index
    }
}
