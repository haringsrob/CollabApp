//
//  DataRequestController.swift
//  SlackDesk
//
//  Created by Rob Harings on 07/07/2017.
//  Copyright © 2017 Rob Harings. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class DataRequestController {
    
    var baseUrl:String = "https://slack.com/api/"
    var endpoint:String

    var connection:Connection
    
    var jsonResponse:JSON?
    
    var parameters:[DataRequestParameter] = [DataRequestParameter]()
    
    init(connection: Connection, endpoint: String) {
        self.connection = connection
        self.endpoint = endpoint
    }
    
    convenience init(connection: Connection, endpoint: String, parameters: [DataRequestParameter]) {
        self.init(connection: connection, endpoint: endpoint)
        self.parameters = parameters
    }
    
    public func addRequestParameter(key: String, value: String) {
        self.parameters.append(DataRequestParameter.init(key: key, value: value))
    }
    
    public func getResponseAsJson(completionHandler: @escaping (JSON?, Error?) -> ()) {
        self.executeRequest(completionHandler: completionHandler)
    }
    
    public func executeRequest(completionHandler: @escaping (JSON?, Error?) -> ()) {
        Alamofire.request(self.getRequestUrl(), parameters: self.getRequestParameters())
            .validate()
            .responseJSON { response in switch response.result {
            case .success(let value):
                completionHandler(JSON(value), nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    private func getRequestParameters() -> [String:Any] {
        var requestParameters: Parameters = ["token":connection.getToken()]
        
        for paramter in self.parameters {
            requestParameters.updateValue(paramter.getValue(), forKey: paramter.getKey())
        }
        
        return requestParameters
    }
    
    private func getRequestUrl() -> String {
        return baseUrl + endpoint;
    }
}
