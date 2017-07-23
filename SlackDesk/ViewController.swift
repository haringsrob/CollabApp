//
//  ViewController.swift
//  SlackDesk
//
//  Created by Rob Harings on 06/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import SwiftHEXColors
import KPCTabsControl

class ViewController: NSViewController, TabsControlDataSource, TabsControlDelegate {

    @IBOutlet weak var Tabs: TabsControl!
    
    @IBOutlet weak var AvailableTabs: NSTabView!
    
    public var setupDispatchGroup:DispatchGroup = DispatchGroup()
    
    private var connections:[Connection] = [Connection]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Tabs.style = DefaultStyle(tabButtonWidth: TabWidth.full)

        self.prepareConnections()
        
        self.setupDispatchGroup.notify(queue: DispatchQueue.main) {
            self.Tabs?.dataSource = self
            self.Tabs?.delegate = self
        }
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    func prepareConnections() {
        let connectionDataSource:ConnectionDatasource = ConnectionDatasource()
        
        let initDispatchGroup:DispatchGroup = DispatchGroup()
        
        var count:Int = 0
        for connection:ConnectionToken in connectionDataSource.connectionsArray {
            let connectionentity:Connection = Connection(name: connection.name, token: connection.token, dispatchGroup: self.setupDispatchGroup, initDispatchGroup: initDispatchGroup)
            
            initDispatchGroup.notify(queue: DispatchQueue.main) {
                if connectionentity.isValidConnection() {
                    
                    connectionentity.initConnection()
                    
                    self.setupDispatchGroup.notify(queue: DispatchQueue.main) {
                        let tabView:NSTabViewItem = NSTabViewItem.init()
                        
                        let newTabView:NSView = self.initalizeConnectionSplitViewForConnection(connection: connectionentity).view
                        
                        tabView.view = newTabView
                        
                        connectionentity.setTabViewItem(tabViewItem: newTabView)
                        connectionentity.setTabIndex(count: count)
                        
                        self.AvailableTabs.addTabViewItem(tabView)
                        
                        self.connections.append(connectionentity)
                        count = count + 1
                        
                        self.Tabs?.reloadTabs()
                        self.Tabs?.selectItemAtIndex(0)
                    }
                }
            }
        }
    }
    
    func initalizeConnectionSplitViewForConnection(connection: Connection) -> ConnectionSplitView {
        let splitView:ConnectionSplitView = ConnectionSplitView(nibName: "ConnectionSplitView", bundle: nil, connection: connection)!
        return splitView;
    }
    
    // Delegate.
    func tabsControlNumberOfTabs(_ control: TabsControl) -> Int {
        return self.connections.count
    }
    
    func tabsControl(_ control: TabsControl, itemAtIndex index: Int) -> AnyObject {
        return self.connections[index]
    }
    
    func tabsControl(_ control: TabsControl, titleForItem item: AnyObject) -> String {
        return (item as! Connection).getName().value
    }
    
    func tabsControlDidChangeSelection(_ control: TabsControl, item: AnyObject) {
        self.AvailableTabs.selectTabViewItem(at: ((item as! Connection).getTabIndex()))
    }
    
    func tabsControl(_ control: TabsControl, canReorderItem item: AnyObject) -> Bool {
        return false
    }


}

