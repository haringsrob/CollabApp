//
//  ConnectionTabViewItem.swift
//  SlackDesk
//
//  Created by Rob Harings on 06/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Cocoa

class ConnectionTabViewItem: NSTabViewItem {

    override init() {
        viewController = ConnectionSplitView()
    }
    
}
