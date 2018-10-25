import Cocoa

class SettingsViewController: NSViewController {
    
    private let deleData: SettingsTableDeleData = SettingsTableDeleData()
    
    @IBOutlet var SettingsTable: NSTableView!
    
    @IBAction func TableActionControl(_ sender: NSSegmentedControl) {
        let segment = sender.selectedSegment
        
        let settingsController: SettingsController = SettingsController()
        
        switch segment {
        case 1: // Remove
            settingsController.removeTokenAtIndex(SettingsTable!.selectedRow)
            break;
            
        case 0: // Add
            settingsController.addConnectionToken(token: "Token", name: "Name")
            break;
        default:
            break;
        }
        
        self.SettingsTable.reloadData()
    }
    
    @IBAction func SaveSettingsButton(_ sender: NSButton) {
        self.writeSettings()
        self.showMessageToRestartClient()
    }
    
    private func writeSettings() {
        let rowCount:Int = self.SettingsTable.numberOfRows
        var count:Int = 0
        
        let settingsController: SettingsController = SettingsController()
        settingsController.removeAllTokens()
        
        for _ in 0..<rowCount {
            let nameView = self.SettingsTable.view(atColumn: 0, row: count, makeIfNecessary: false) as! NSTableCellView
            let tokenView = self.SettingsTable.view(atColumn: 1, row: count, makeIfNecessary: false) as! NSTableCellView
            
            settingsController.addConnectionToken(token: (tokenView.textField?.stringValue)!, name: (nameView.textField?.stringValue)!)
            count = count + 1
        }
    }
    
    private func showMessageToRestartClient() {
        let alert = NSAlert()
        alert.messageText = "Settings have been saved"
        alert.informativeText = "Please restart your client to show the new team"
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.SettingsTable.delegate = self.deleData
        self.SettingsTable.dataSource = self.deleData
    }
    
}

class SettingsTableDeleData: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    // Datasource
    func numberOfRows(in tableView: NSTableView) -> Int {
        let settingsController: SettingsController = SettingsController()
        return settingsController.getConnectionTokens().count
    }
    
    // Delegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let settingsController: SettingsController = SettingsController()
        
        var view: NSTableCellView?
        var item:String
        
        
        var identifier:String = "connectionName"
        
        do {
            let connection:Connection = try settingsController.getTokenAtIndex(row)
            
            if tableColumn?.identifier.rawValue == "connectionName" {
                item = connection.getName()
            }
            else {
                identifier = "connectionToken"
                item = connection.getKey()
            }
            
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier), owner: self) as? NSTableCellView
            
            if let textField = view?.textField {
                textField.stringValue = String(describing: item)
            }
        }
        catch {
            // Nothing to do
        }
        
        return view
    }
}
