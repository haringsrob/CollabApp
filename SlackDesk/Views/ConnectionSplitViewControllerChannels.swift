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
        var cellId: String = "DataCellRegular"
        
        let channel:Channel = self.connection.getChannels().value[row];
        
        switch channel.getType() {
        case Channel.directMessage:
            cellId = "DataCellDM"
            break
        case Channel.lockedChannel:
            cellId = "DataCellLocked"
            break;
        case Channel.userGroup:
            cellId = "DataCellGroup"
        default:
            break;
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellId), owner: nil) as? NSTableCellView {
            
            if (channel.getType() == Channel.directMessage) {
                do {
                    try cell.textField?.stringValue = self.connection.findUserById(channel.getName()).getName()
                }
                catch {
                    // @todo Change this duplication.
                    cell.textField?.stringValue = channel.getName()
                }
            }
            else {
                cell.textField?.stringValue = channel.getName()
            }
            
            return cell
        }
        return nil
    }
}
