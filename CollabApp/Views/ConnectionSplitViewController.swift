import Cocoa
import Smile
import Down
import RxSwift

class ConnectionSplitViewController: NSSplitViewController {
    @IBOutlet var Messages: NSTableView!
    @IBOutlet var ChannelList: NSTableView!
    @IBOutlet var UsersList: NSTableView!
    
    public var connection: Connection = Connection()
    private var channelsDeleData: ConnectionSplitViewControllerChannels?
    private var messagesDeleData: ConnectionSplitViewControllerMessages?
    private var usersDeleData: ConnectionSplitViewControllerUsers?
    
    private var socket: SlackWebSocketClient!
    @IBOutlet var MessageBox: NSTextField!
    
    private var activeChannel:Channel?
    
    @IBOutlet var DragView: DragView!
    @IBOutlet var DragViewLoader: NSProgressIndicator!
    @IBOutlet var DragViewLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ChannelList.delegate = self.channelsDeleData
        self.ChannelList.dataSource = self.channelsDeleData
        
        self.Messages.delegate = self.messagesDeleData
        self.Messages.dataSource = self.messagesDeleData
        
        self.UsersList.delegate = self.usersDeleData
        self.UsersList.dataSource = self.usersDeleData
        
        self.DragView.delegate = self
        
        self.DragViewLoader.isHidden = true
        self.DragViewLabel.isHidden = true
        
        self.initializeChannels()
        self.initializeUsers()
    }
    
    public func setConnection(connection: Connection)-> Void {
        self.connection = connection
        self.channelsDeleData = ConnectionSplitViewControllerChannels(connection: self.connection)
        self.messagesDeleData = ConnectionSplitViewControllerMessages(connection: self.connection)
        self.usersDeleData = ConnectionSplitViewControllerUsers(connection: self.connection)
        
        self.socket = SlackWebSocketClient(connection: connection)
        self.socket.startWebSocket()
    }
    
    private func initializeChannels() {
        _ = self.connection.getChannels().asObservable().subscribe() { event in
            switch event {
            case .next(_):
                self.ChannelList.reloadData()
                
                // When a channel has updated data mark it.
                for channel in self.connection.getChannels().value {
                    _ = channel.hasUnreadMessage.asObservable().subscribe() { event in
                        switch event {
                        case .next(_):
                            // Reload the data and update the selection.
                            let selectedRow = self.ChannelList.selectedRowIndexes
                            self.ChannelList.reloadData()
                            self.ChannelList.selectRowIndexes(selectedRow, byExtendingSelection: false)
                            break;
                        case .error(_): break
                        case .completed: break
                        }
                    }
                }
                
                break;
            case .error(_): break
            case .completed: break
            }
        }
        
        let channelController:ChannelController = ChannelController(connection: self.connection)
        channelController.updateChannelList(completion: {_,_ in })
    }
    
    private func initializeUsers() {
        _ = self.connection.getUsers().asObservable().subscribe() { event in
            switch event {
            case .next(_):
                self.UsersList.reloadData()
                break;
            case .error(_): break
            case .completed: break
            }
        }
        let userListController:UserListController = UserListController(connection: self.connection)
        userListController.updateUserList(completion: {_,_ in })
    }
    
    private func sendMessageToActiveChannelAndClearInputField() {
        if self.activeChannel != nil {
            if !self.MessageBox.stringValue.isEmpty {
                self.socket.sendMessage(message: self.MessageBox.stringValue, channel: self.activeChannel!)
                self.MessageBox.stringValue = ""
            }
        }
    }
    
    // The channel has been changed.
    @IBAction func ChannelChanged(_ sender: Any) {
        let channel: Channel = self.connection.getChannels().value[ChannelList.selectedRow]
        
        channel.hasUnreadMessage.value = false
        
        // Do nothing if we select the same channel.
        if (channel.getId() == self.activeChannel?.getId()) {
            return
        }
        
        self.messagesDeleData?.setChannel(channel: channel)
        self.activeChannel = channel
        
        if (channel.getMessages().value.isEmpty) {
            let channelController:ChannelController = ChannelController(connection: self.connection)
            channelController.getHistoryForChannel(channel: channel, completion: {_,_ in })
        }
        
        _ = channel.getMessagesLoaded().asObservable().subscribe() { event in
            switch event {
            case .next(_):
                if channel.messagesLoaded.value {
                    self.startMessageObserver(channel)
                    self.Messages.reloadData()
                    self.Messages.scrollRowToVisible(self.Messages.numberOfRows - 1)
                }
                break;
            case .error(_):
                break
            case .completed:
                break
            }
        }
    }
    
    private func startMessageObserver(_ channel: Channel) {
        _ = channel.getMessages().asObservable().subscribe() { event in
            switch event {
            case .next(_):
                self.Messages.reloadData()
                self.Messages.scrollRowToVisible(self.Messages.numberOfRows - 1)
                break;
            case .error(_): break
            case .completed:
                break
            }
        }
    }
    
    // A message has been send by pressing "Enter".
    @IBAction func SubmitMessage(_ sender: Any) {
        self.sendMessageToActiveChannelAndClearInputField()
    }
    
    // A message has been send by pressing the send button.
    @IBAction func SubmitMessageByButton(_ sender: Any) {
        self.sendMessageToActiveChannelAndClearInputField()
    }
    
}

// Drag and dropping.
extension ConnectionSplitViewController: DragViewDelegate {
    func dragView(didDragFileWith URL: NSURL) {
        if (self.activeChannel == nil) {
            let alert = NSAlert()
            alert.messageText = "No active channel, select a channel before uploading files"
            alert.alertStyle = NSAlert.Style.informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        else {
            self.DragViewLoader.isHidden = false
            self.DragViewLoader.startAnimation(self)
            let client: SlackClient = SlackClient.init(apiKey: self.connection.getKey())
            client.uploadFile(file: URL, channel: self.activeChannel!){ response, error in
                self.DragViewLoader.isHidden = true
            }
        }
    }
    
    func fileEnter() {
        self.DragViewLabel.isHidden = false
    }
    
    func fileExit() {
        self.DragViewLabel.isHidden = true
    }
}
