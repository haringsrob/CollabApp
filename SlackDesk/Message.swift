//
//  Message.swift
//  SlackDesk
//
//  Created by Rob Harings on 07/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import Down
import Regex

class Message {
    
    var message:String
    var userId:String
    var ts:String
    
    public var connection:Connection
    public var messageAttributeString:NSAttributedString
    
    var messageView:MessageListItem!
    
    init(message: String, userId: String, ts: String, connection: Connection) {
        self.ts = ts
        self.message = message
        
        let replaced:String = ("<@([A-Z]\\w+){1}(\\|.+)?>".r?.replaceAll(in: message) { match in
            if match.group(at: 1) != nil {
                return "@" + (connection.users?.findUserForId(id: match.group(at: 1)!).name)!
            }
            return nil
        })!
        
        // Trim the last linebreak.
        let updatableMessage:NSMutableAttributedString = NSMutableAttributedString(attributedString: try! Down(markdownString: replaced.emojiUnescapedString).toAttributedString())
        if (updatableMessage.string.last == "\n") {
            updatableMessage.deleteCharacters(in: NSRange(location: updatableMessage.length-1, length: 1))
        }
        
        self.messageAttributeString = updatableMessage.copy() as! NSAttributedString;

        self.userId = userId
        self.connection = connection
    }
    
    public func append(message: String) {
        self.message = self.message + " " + message;
    }
    
    public func getTextView() -> String {
        return (self.connection.users?.findUserForId(id: self.userId).name)! + ": " + self.message
    }
    
    public func getRowSize() -> CGFloat {
        self.getView().layoutSubtreeIfNeeded()
        return self.getView().frame.size.height
    }
    
    public func getView() -> NSView {
        if self.messageView == nil {
            self.messageView = MessageListItem.init(nibName: "MessageListItem", bundle: nil, message: self)!
        }
        return self.messageView.view
    }

}
