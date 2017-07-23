//
//  SettingsController.swift
//  SlackDesk
//
//  Created by Rob Harings on 19/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa

class SettingsController: NSViewController {
    
    private var connectionsDatasource:ConnectionDatasource = ConnectionDatasource()
    
    @IBOutlet weak var SettingsTableView: NSTableView!
    
    @IBAction func TableActionControl(_ sender: NSSegmentedControl) {
        let segment = sender.selectedSegment
        
        switch segment {
            case 1: // Remove
                SettingsTableView.removeRows(at: SettingsTableView.selectedRowIndexes)
                break;
                
            case 0: // Add
                self.connectionsDatasource.connectionsArray.append(ConnectionToken(name: "Insert name", token: "Insert token"))
                SettingsTableView.reloadData()
                break;
            default:
                break;
        }
    }
    
    @IBAction func SaveSettingsButton(_ sender: NSButton) {
        self.updateSettingsWithTableData()
        
        self.showMessageToRestartClient()
    }
    
    private func showMessageToRestartClient() {
        let alert = NSAlert()
        alert.messageText = "Settings have been saved"
        alert.informativeText = "Please restart your client to show the new team"
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func updateSettingsWithTableData() {
        let rowCount:Int = self.SettingsTableView.numberOfRows
        
        self.connectionsDatasource.connectionsArray.removeAll()
        
        var count:Int = 0
        
        for _ in 0..<rowCount {
            let nameView = self.SettingsTableView.view(atColumn: 0, row: count, makeIfNecessary: false) as! NSTableCellView
            let tokenView = self.SettingsTableView.view(atColumn: 1, row: count, makeIfNecessary: false) as! NSTableCellView
            
            self.connectionsDatasource.connectionsArray.append(ConnectionToken(name: (nameView.textField?.stringValue)!, token: (tokenView.textField?.stringValue)!))
            
            count = count + 1
        }
        
        let connections:NSMutableDictionary = [:]
        
        for connectionToken:ConnectionToken in self.connectionsDatasource.connectionsArray {
            connections[connectionToken.name] = connectionToken.token
        }
        
        let defaults = UserDefaults.standard
        defaults.set(connections, forKey: "userSettings")
        SettingsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SettingsTableView.dataSource = self.connectionsDatasource as NSTableViewDataSource
        SettingsTableView.delegate = self.connectionsDatasource as NSTableViewDelegate
    }
    
}
