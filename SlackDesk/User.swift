//
//  User.swift
//  SlackDesk
//
//  Created by Rob Harings on 07/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Foundation

class User {
    
    var name:String
    public var id:String
    var presence:String
    
    init(name: String, id: String, presence: String) {
        self.name = name
        self.id = id
        self.presence = presence
    }
}
