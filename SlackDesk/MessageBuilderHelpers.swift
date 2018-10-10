//
//  MessageBuilderHelpers.swift
//  SlackDesk
//
//  Created by Rob Harings on 10/10/2018.
//  Copyright © 2018 Rob Harings. All rights reserved.
//

import Foundation
import SwiftyJSON

class MessageBuilderHelpers {
    
    public static func getTextForMessage(JsonMessage: JSON) -> String {
        var fullMessage:String = "";
        fullMessage += JsonMessage["text"].string!
        // Manage file. Duplicated in ConnectionWebSocketClient.swift
        if (!JsonMessage["files"].isEmpty){
            for file in JsonMessage["files"].arrayValue {
                let fileName = file["name"].string!;
                let privateUrl = file["url_private"].string!;
                
                // @todo: All left here is to put ! in front of the first [. However
                // we need permission for those urls. Havent found the correct documentation.
                fullMessage += "[" + fileName + "](" + privateUrl + ")"
            }
        }
        return fullMessage
    }
    
}
