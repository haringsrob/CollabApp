//
//  ChannelMessageListView.swift
//  SlackDesk
//
//  Created by Rob Harings on 07/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa

class ChannelMessageListView: NSViewController {
   
    @IBOutlet weak var MessageList: NSOutlineView!
    
    private var channel:Channel?
    private var connection:Connection?
    
    private var messageDatasource:MessagesDatasource?
    
    public func setConnectionAndChannel(connection: Connection, channel: Channel) {
        self.channel = channel
        self.connection = connection
        
        messageDatasource = MessagesDatasource(connection: connection, channelView: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MessageList.dataSource = self.messageDatasource
        MessageList.delegate = self.messageDatasource
    }
    
}
