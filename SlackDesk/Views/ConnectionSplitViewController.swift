//
//  ConnectionSplitViewController.swift
//  SlackDesk
//
//  Created by Rob Harings on 15/10/2018.
//  Copyright © 2018 Rob Harings. All rights reserved.
//

import Cocoa
import RxSwift

class ConnectionSplitViewController: NSSplitViewController {
    @IBOutlet var Messages: NSTableView!
    @IBOutlet var ChannelList: NSTableView!
    
    public var connection: Connection = Connection()
    private var channelsDeleData: ConnectionSplitViewControllerChannels?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeChannels()
        self.ChannelList.delegate = self.channelsDeleData
        self.ChannelList.dataSource = self.channelsDeleData
    }
    
    public func setConnection(connection: Connection)-> Void {
        self.connection = connection
        self.channelsDeleData = ConnectionSplitViewControllerChannels(connection: connection)
    }
    
    private func initializeChannels() {
        _ = self.connection.getChannels().asObservable().subscribe() { event in
            switch event {
            case .next(_):
                self.ChannelList.reloadData()
                break;
            case .error(_): break
            case .completed: break
            }
        }
        let channelController:ChannelController = ChannelController(connection: self.connection)
        channelController.updateChannelList(completion: {_,_ in })
    }
    
}

class ConnectionSplitViewControllerChannels: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    public var connection: Connection
    
    init(connection: Connection) {
        self.connection = connection
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.connection.getChannels().value.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let item: Channel = self.connection.getChannels().value[row] else {
            return nil
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = item.getName()
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let item: Channel = self.connection.getChannels().value[row] else {
            return nil
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = item.getName()
            return cell
        }
        return nil
    }
    
}
