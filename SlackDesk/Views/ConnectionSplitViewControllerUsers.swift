import Cocoa

class ConnectionSplitViewControllerUsers: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    public var connection: Connection
    
    init(connection: Connection) {
        self.connection = connection
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.connection.getUsers().value.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let user: User = self.connection.getUsers().value[row];
        var cell: String = "OfflineCell"
        if user.isConnected.value {
            cell = "OnlineCell"
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cell), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = user.getName()
            return cell
        }
        return nil
    }
}
