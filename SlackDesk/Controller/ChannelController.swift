import Foundation
import SwiftyJSON

class ChannelController {
    
    private var connection:Connection;
    
    init(connection: Connection) {
        self.connection = connection;
    }
    
    public func updateChannelList(completion: @escaping (Bool, Error?) -> Void) {
        let client:SlackClient = SlackClient(apiKey: self.connection.getKey())
        client.conversationsList() { response, error in
            for (_,subJson):(String, JSON) in response {
                // Do something you want
                let channel:Channel = Channel()
                channel.setName(subJson["name"].stringValue)
                channel.setId(subJson["id"].stringValue)
                self.connection.addChannel(channel)
            }
            completion(true, error)
            
        }
    }
    
}
