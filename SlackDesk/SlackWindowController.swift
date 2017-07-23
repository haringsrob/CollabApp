//
//  SlackWindowController.swift
//  SlackDesk
//
//  Created by Rob Harings on 22/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import SwiftHEXColors

class SlackWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        self.window?.titleVisibility = .hidden
        self.window?.titlebarAppearsTransparent = true
        self.window?.styleMask.insert(.fullSizeContentView)
        
        self.window?.backgroundColor = NSColor(hexString: "fff")
    }

}
