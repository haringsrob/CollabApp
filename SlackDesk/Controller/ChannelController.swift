import Foundation
import SwiftyJSON

class ChannelController: ClientAccesingControllerBase {
    
    public func updateChannelList(completion: @escaping (Bool, Error?) -> Void) {
        self.getClient().conversationsList() { response, error in
            for (_,subJson):(String, JSON) in response {
                let channel:Channel = Channel()
                channel.setName(subJson["name"].stringValue)
                channel.setId(subJson["id"].stringValue)
                self.connection.addChannel(channel)
            }
            completion(true, error)
            
        }
    }
    
    public func getHistoryForChannel(channel: Channel, completion: @escaping(Bool, Error?) -> Void) {
        self.getClient().conversationsHistory(channelId: channel.getId()) { response, error in
            for (_,subJson):(String, JSON) in response {
                let message:Message = Message()
                message.setBody(subJson["text"].stringValue)
                message.setUserId(subJson["user"].stringValue)
                message.setTimeStamp(subJson["ts"].stringValue)
                channel.addMessage(message)
            }
            completion(true, error)
            
        }
    }
    
}
