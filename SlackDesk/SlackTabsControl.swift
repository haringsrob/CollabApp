//
//  SlackTabsControl.swift
//  SlackDesk
//
//  Created by Rob Harings on 23/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa
import KPCTabsControl

class SlackTabsControl: TabsControl {

    open override var mouseDownCanMoveWindow: Bool {
        return false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}
