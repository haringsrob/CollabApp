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
    
    public func usersList(completion: @escaping (JSON, Error?) -> Void) {
        self.getRequest(method: "users.list", parameters: ["presence": "true"]).responseJSON { response in
            switch response.result {
            case .success:
                completion(JSON(response.result.value!)["members"],  nil)
            case .failure(let error):
                completion(JSON("{}"), error)
            }
        }
    }
    
    public func conversationsList(completion: @escaping (JSON, Error?) -> Void) {
        self.getRequest(method: "conversations.list", parameters: [
            "types": "public_channel,private_channel,mpim,im",
            "limit": 1000,
            "exclude_archived": "true"
            ]).responseJSON { response in
                switch response.result {
                case .success:
                    completion(JSON(response.result.value!)["channels"],  nil)
                case .failure(let error):
                    completion(JSON("{}"), error)
                }
        }
    }
    
    public func conversationsHistory(channelId: String, completion: @escaping(JSON, Error?) -> Void) {
        self.getRequest(method: "conversations.history", parameters: [
            "channel": channelId,
            "limit": 1000,
            ]).responseJSON { response in
                switch response.result {
                case .success:
                    completion(JSON(response.result.value!)["messages"],  nil)
                case .failure(let error):
                    completion(JSON("{}"), error)
                }
        }
    }
    
    public func getRTMconnectionUrl(completion: @escaping(String, Error?) -> Void) {
        self.getRequest(method: "rtm.connect").responseJSON { response in
            switch response.result {
            case .success:
                completion(JSON(response.result.value!)["url"].stringValue,  nil)
            case .failure(let error):
                completion("", error)
            }
        }
    }
    
    public func uploadFile(file: NSURL, channel: Channel, completion: @escaping(JSON, Error?) -> Void) {
        let urlString: String = self.endpoint + "files.upload?token=" + self.apiKey + "&channels=" + channel.getId()
        let fileUri: URL = file as URL
        
        Alamofire.upload(multipartFormData: { (data: MultipartFormData) in
            data.append(fileUri, withName: "file")
        }, to: urlString, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    completion(JSON(response.result.value!),  nil)
                }
            case .failure(let encodingError):
                completion("", encodingError)
            }
        }
        )
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
