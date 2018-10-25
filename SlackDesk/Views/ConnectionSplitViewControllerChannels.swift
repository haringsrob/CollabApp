import Cocoa

class ConnectionSplitViewControllerChannels: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    public var connection: Connection
    
    init(connection: Connection) {
        self.connection = connection
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.connection.getChannels().value.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = self.connection.getChannels().value[row].getName()
            return cell
        }
        return nil
    }
}
