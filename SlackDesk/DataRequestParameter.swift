//
//  DataRequestParameter.swift
//  SlackDesk
//
//  Created by Rob Harings on 07/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Foundation

class DataRequestParameter {

    var key:String
    var value:String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    public func getKey() -> String {
        return self.key
    }
    
    public func getValue() -> String {
        return self.value
    }

}
