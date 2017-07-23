//
//  UsersDatasource.swift
//  SlackDesk
//
//  Created by Rob Harings on 07/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import SwiftyJSON
import ReactiveSwift
import ReactiveCocoa

class UsersDatasource: NSObject, NSTableViewDataSource, NSTableViewDelegate  {
    
    public var connection:Connection
    
    init(connection: Connection) {
        self.connection = connection
        super.init()
        self.loadAllUsers()
    }
    
    private func loadAllUsers() {
        self.connection.usersSetupDispatchGroup.enter()
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self.connection, endpoint: "users.list")
        connectionDataRequest.addRequestParameter(key: "presence", value: "true")
        connectionDataRequest.getResponseAsJson() { responseJSON, error in
            for (_, user) in (responseJSON?["members"])! {
                let user:User = User(
                    name: (user["name"].string)!,
                    id: (user["id"].string)!,
                    presence: self.getPresenceForUserJSON(user: user)
                )
                self.connection.userStore.users.value.append(user)
            }
            
            self.connection.usersSetupDispatchGroup.leave()
        }
    }
    
    public func findUserForId(id: String) -> User {
        if self.connection.userStore.users.value.first(where: { $0.id == id }) != nil {
            return self.connection.userStore.users.value.first(where: { $0.id == id })!
        }
        return self.createUserForBot(id: id)
    }
    
    private func createUserForBot(id: String) -> User {
        var user:User!
        let connectionDataRequest:DataRequestController = DataRequestController(connection: self.connection, endpoint: "bots.info")
        connectionDataRequest.addRequestParameter(key: "bot", value: id)
        connectionDataRequest.getResponseAsJson() { responseJSON, error in
            if let _ = responseJSON?["bot"].string {
                user = User(name: (responseJSON?["bot"]["name"].string)!, id: (responseJSON?["bot"]["id"].string)!, presence: "away")
            }
        }
        if user == nil {
            user = User(name: "unknown", id: "unknown", presence: "away")
        }
        return user
    }
    
    private func getPresenceForUserJSON(user: JSON) -> String {
        if let presence = user["presence"].string {
            return presence
        }
        return "away"
    }
    
    // Datasource
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.connection.userStore.users.value.count
    }
    
    // Delegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: NSTableCellView?
        let userItem:User = self.connection.userStore.users.value[row]
        
        var identifier:String
        
        switch userItem.presence {
        case "active":
            identifier = "OnlineCell"
        default:
            identifier = "OfflineCell"
        }
        
        view = tableView.make(withIdentifier: identifier, owner: self) as? NSTableCellView
        
        if let textField = view?.textField {
            textField.stringValue = String(describing: userItem.name)
        }
        return view
    }
}
