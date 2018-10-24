import Cocoa
import Smile
import Down
import RxSwift

class ConnectionSplitViewController: NSSplitViewController {
    @IBOutlet var Messages: NSTableView!
    @IBOutlet var ChannelList: NSTableView!
    
    public var connection: Connection = Connection()
    private var channelsDeleData: ConnectionSplitViewControllerChannels?
    private var messagesDeleData: ConnectionSplitViewControllerMessages?
    
    private var socket: SlackWebSocketClient!
    @IBOutlet var MessageBox: NSTextField!
    
    private var activeChannel:Channel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ChannelList.delegate = self.channelsDeleData
        self.ChannelList.dataSource = self.channelsDeleData
        
        self.Messages.delegate = self.messagesDeleData
        self.Messages.dataSource = self.messagesDeleData
        
        self.initializeChannels()
    }
    
    @IBAction func ChannelChanged(_ sender: Any) {
        let channel: Channel = self.connection.getChannels().value[ChannelList.selectedRow]
        
        self.messagesDeleData?.setChannel(channel: channel)
        self.activeChannel = channel
        let channelController:ChannelController = ChannelController(connection: self.connection)
        
        if (channel.getMessages().value.isEmpty) {
            channelController.getHistoryForChannel(channel: channel, completion: {_,_ in })
            self.Messages.reloadData()
        }
        
        _ = channel.getMessages().asObservable().subscribe() { event in
            switch event {
            case .next(_):
                self.Messages.reloadData()
                break;
            case .error(_): break
            case .completed: break
            }
        }
    }
    
    public func setConnection(connection: Connection)-> Void {
        self.connection = connection
        self.channelsDeleData = ConnectionSplitViewControllerChannels(connection: self.connection)
        self.messagesDeleData = ConnectionSplitViewControllerMessages(connection: self.connection)
        
        self.socket = SlackWebSocketClient(connection: connection)
        self.socket.startWebSocket()
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
    
    // A message has been send by pressing "Enter".
    @IBAction func SubmitMessage(_ sender: Any) {
        self.sendMessageToActiveChannelAndClearInputField()
    }
    
    // A message has been send by pressing the send button.
    @IBAction func SubmitMessageByButton(_ sender: Any) {
        self.sendMessageToActiveChannelAndClearInputField()
    }
    
    private func sendMessageToActiveChannelAndClearInputField() {
        if self.activeChannel != nil {
            if !self.MessageBox.stringValue.isEmpty {
                self.socket.sendMessage(message: self.MessageBox.stringValue, channel: self.activeChannel!)
                self.MessageBox.stringValue = ""
            }
        }
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
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DataCell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = self.connection.getChannels().value[row].getName()
            return cell
        }
        return nil
    }
}

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
        if self.channel == nil {
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
                cell.textField?.attributedStringValue = item.getBody()
            }
            else {
                cell.textField?.stringValue = item.getUserId()
            }
            
            return cell
        }
        return nil
    }
}
