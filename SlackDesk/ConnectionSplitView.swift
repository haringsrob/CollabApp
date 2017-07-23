//
//  ConnectionSplitView.swift
//  SlackDesk
//
//  Created by Rob Harings on 06/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import Observable
import ReactiveCocoa
import ReactiveSwift

class ConnectionSplitView: NSSplitViewController {

    public var connection:Connection?
    private var webSocketClient:ConnectionWebSocketClient!
    
    @IBOutlet weak var LabelField: NSTextField!
    @IBOutlet weak var ChannelName: NSTextField!
    @IBOutlet weak var messageTextField: NSTextField!
    @IBOutlet weak var ChannelList: NSTableView!
    @IBOutlet weak var UsersList: NSTableView!
    @IBOutlet weak var MessagesList: NSTableView!

    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, connection: Connection) {
        self.connection = connection
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setConnectionNameLabel()
        self.setUserListDelegateAndDatasource()
        self.setChannelListDelegateAndDatasource()
        self.setChannelNameLabel()
        
        self.connection?.usersSetupDispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
            self.UsersList.reactive.reloadData <~ self.connection!.userStore.users.map { _ in }
            
            // Start the websocket.
            self.webSocketClient = ConnectionWebSocketClient.init(connection: (self.connection)!)
            self.webSocketClient.startWebSocket()
        }
        
        self.connection?.channelSetupDispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
            self.connection!.channels?.sortChannels()
            self.ChannelList.reactive.reloadData <~ self.connection!.channelStore.channels.map { _ in }
        }
        
        self.connection?.getActiveChannelProperty().signal.observe {channel in
            channel.value?.messageDataSource.loadAllMessages()
            self.MessagesList.delegate = channel.value?.messageDataSource
            self.MessagesList.dataSource = channel.value?.messageDataSource
            
            self.connection!.getActiveChannel().messageDataSource.messageStore.messages.signal.observe {_ in
                self.MessagesList.reloadData()
                self.scrollMessageListToBottomIfNotScrolled()
            }
            
            self.MessagesList.reloadData()
        }
        
        self.connection?.refreshChannel.signal.observe {value in
            let row = IndexSet(integer: value.value!)
            let column = IndexSet(integer: 0)
            self.ChannelList.reloadData(forRowIndexes: row, columnIndexes: column)
        }
        
        self.connection?.refreshUsers.signal.observe {value in
            self.UsersList.reloadData()
        }
    }

    private func setConnectionNameLabel() {
        self.LabelField.reactive.stringValue <~ self.connection!.getName()
    }
    
    private func setChannelNameLabel() {
        self.connection?.getActiveChannelProperty().signal.observe {channel in
            self.ChannelName.stringValue = (channel.value?.name)!
        }
    }
    
    private func setChannelListDelegateAndDatasource() {
        self.ChannelList.dataSource = self.connection?.channels
        self.ChannelList.delegate = self.connection?.channels
    }
    
    private func setUserListDelegateAndDatasource() {
        self.UsersList.dataSource = self.connection?.users
        self.UsersList.delegate = self.connection?.users
    }
    
    private func scrollMessageListToBottomIfNotScrolled() {
        self.MessagesList.scrollRowToVisible(self.MessagesList.numberOfRows - 1)
    }

    @IBAction func ChannelChangeFunction(_ sender: NSTableView) {
        if sender.selectedRow != -1 {
            let channel:Channel = (self.connection?.channelStore.channels.value[sender.selectedRow])!
            channel.resetUnreadCount()
            self.connection?.setActiveChannel(channel: channel)
            self.scrollMessageListToBottomIfNotScrolled()
        }
    }
    
    @IBAction func sendMessageAction(_ sender: NSTextField) {
        self.sendMessageToActiveChannelAndClearInputField()
    }
    @IBAction func SendMessageButtonAction(_ sender: NSButton) {
        self.sendMessageToActiveChannelAndClearInputField()
    }
    
    private func sendMessageToActiveChannelAndClearInputField() {
        if let channel:Channel = self.connection?.getActiveChannel() {
            if !self.messageTextField.stringValue.isEmpty {
                self.webSocketClient.sendMessage(message: self.messageTextField.stringValue, channel: channel)
                self.messageTextField.stringValue = ""
            }
        }
    }
    
    /**
     * Mandatory initializer.
     */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
