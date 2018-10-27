import Cocoa

class ConnectionSplitViewControllerMessages: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    public var connection: Connection
    public var channel: Channel?
    
    init(connection: Connection) {
        self.connection = connection
    }
    
    public func setChannel(channel: Channel) {
        self.channel = channel
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.channel?.getMessages().value.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if self.channel == nil || !(self.channel?.messagesLoaded.value)! {
            return nil
        }
        var cellIdentifier: String = ""
        
        let item: Message = (self.channel?.getMessages().value[row])!;
        
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = "NameCell"
        } else if tableColumn == tableView.tableColumns[1] {
            cellIdentifier = "DataCell"
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            if tableColumn == tableView.tableColumns[1] {
                cell.textField?.attributedStringValue = replaceLinksAndGetAttributedString(item.getBody().value, connection: self.connection)
            }
            else {
                do {
                    cell.textField?.stringValue = try self.connection.findUserById(item.getUserId()).getName()
                }
                catch ChannelException.userWithIdNotFound {
                    cell.textField?.stringValue = item.getUserId()
                }
                catch {
                    print("Unexpected error: \(error).")
                }
            }
            
            return cell
        }
        return nil
    }
}
