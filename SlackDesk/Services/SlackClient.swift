import Foundation
import Alamofire
import SwiftyJSON

/**
 * SlackClient is the base communicator for regular web api calls.
 */
class SlackClient {
    
    public var endpoint:String = "https://slack.com/api/"
    public var apiKey:String;
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func setEndpoint(_ endpoint:String) -> Void {
        self.endpoint = endpoint;
    }
    
    public func conversationsList(completion: @escaping (JSON, Error?) -> Void) {
        self.getRequest(method: "conversations.list", parameters: [
            "types": "public_channel,private_channel,mpim,im",
            "limit": 1000,
        ]).responseJSON { response in
            switch response.result {
                case .success:
                    completion(JSON(response.result.value!),  nil)
                case .failure(let error):
                    completion(JSON("{}"), error)
            }
        }
    }
    
    private func getRequest(method: String, parameters:Parameters = [:]) -> DataRequest {
        let parameters = self.getBasicParameters().merging(parameters){ (_, new) in new };
        return Alamofire.request(self.endpoint + method, parameters: parameters);
    }
    
    private func getBasicParameters() -> Parameters {
        return [
            "token": self.apiKey,
        ]
    }
    
}
