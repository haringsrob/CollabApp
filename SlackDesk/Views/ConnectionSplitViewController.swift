//
//  ConnectionSplitViewController.swift
//  SlackDesk
//
//  Created by Rob Harings on 15/10/2018.
//  Copyright © 2018 Rob Harings. All rights reserved.
//

import Cocoa

class ConnectionSplitViewController: NSSplitViewController {
    @IBOutlet var ChannelList: NSOutlineView!
    
    public var connection: Connection = Connection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func setConnection(connection: Connection)-> Void {
        self.connection = connection
        
        let channelController:ChannelController = ChannelController(connection: self.connection)
        channelController.updateChannelList() {response, error in
        }
    }
}

extension ConnectionSplitViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if (item != nil) {
            return 0
        }
        return connection.getChannels().count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return connection.getChannels()[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

}

extension ConnectionSplitViewController: NSOutlineViewDelegate {
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
