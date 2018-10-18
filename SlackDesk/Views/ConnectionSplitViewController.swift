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
    @IBOutlet var ChannelList: NSOutlineView!
    @IBOutlet var Messages: NSTableView!
    
    public var connection: Connection = Connection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeChannels()
    }
    
    public func setConnection(connection: Connection)-> Void {
        self.connection = connection
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
    
    @IBAction func ChannelChangeAction(_ sender: NSOutlineView) {
        let a = 0;
    }
}

extension ConnectionSplitViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if (item != nil) {
            return 0
        }
        return self.connection.getChannels().value.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
       return connection.getChannels().value[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
}

extension ConnectionSplitViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let a = 0;
    }
    
//    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
//        var view: NSTableCellView?
//
//        if let feed = item as? Channel {
//            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
//            if let textField = view?.textField {
//                textField.stringValue = feed.getName()
//                textField.sizeToFit()
//            }
//        }
//
//        return view
//    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?

        if let feed = item as? Channel {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = feed.getName()
                textField.sizeToFit()
            }
        }

        return view
    }
}

extension ConnectionSplitViewController: NSTableViewDataSource {
    
}

extension ConnectionSplitViewController: NSTableViewDelegate {
    // Delegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: NSTableCellView?
//        let channelItem:Channel = self.connection.channelStore.channels.value[row]
//        channelItem.setRowId(row: row)
//
//        var identifier:String
//
//        view = tableView.make(withIdentifier: "DataCell", owner: self) as? NSTableCellView
//        if let textField = view?.textField {
//            textField.stringValue = String(describing: channelItem.getName())
//        }
        return view
    }
}
