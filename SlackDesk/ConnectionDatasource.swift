//
//  ConnectionDatasource.swift
//  SlackDesk
//
//  Created by Rob Harings on 19/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa

class ConnectionDatasource: NSObject, NSTableViewDataSource, NSTableViewDelegate{

    public var connections:NSDictionary = [:]
    public var connectionsArray:[ConnectionToken] = []
    
    override init() {
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: "userSettings") != nil) {
            self.connections = defaults.object(forKey: "userSettings") as! NSDictionary
        }

        for connection in connections {
            connectionsArray.append(ConnectionToken(name: connection.key as! String, token: connection.value as! String))
        }
    }
 
    // Datasource
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.connectionsArray.count
    }
    
    // Delegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: NSTableCellView?
        var item:String
        
        var identifier:String = "connectionName"
        if connectionsArray.indices.contains(row) {
            item = connectionsArray[row].name
        }
        else {
            item = "Insert name"
        }
        
        if tableColumn?.identifier != "connectionName" {
            identifier = "connectionToken"
            
            if connectionsArray.indices.contains(row) {
                item = connectionsArray[row].token
            }
            else {
                item = "Insert token"
            }
        }
        
        view = tableView.make(withIdentifier: identifier, owner: self) as? NSTableCellView
        
        if let textField = view?.textField {
            textField.stringValue = String(describing: item)
        }
        return view
    }
}
