//
//  MessageListItem.swift
//  SlackDesk
//
//  Created by Rob Harings on 12/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import Down
import Emoji

class MessageListItem: NSViewController {
    
    private var message:Message!

    @IBOutlet weak var UserName: NSTextField!
    @IBOutlet weak var Message: NSTextField!
    
    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, message: Message) {
        self.message = message;
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.message != nil {            
            self.UserName.stringValue = (message.connection.users?.findUserForId(id: message.userId).name)!
            self.Message.attributedStringValue = message.messageAttributeString
            
            self.updateSize()

            self.view.frame.size.height = self.Message.bounds.height
        }
    }
    
    public func updateSize() {
        self.Message.sizeToFit()
    }
    
    /**
     * Required by xcode.
     */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
