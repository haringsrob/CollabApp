import Foundation
import SwiftyJSON

class UserListController: ClientAccesingControllerBase {
    
    public func updateUserList(completion: @escaping (Bool, Error?) -> Void) {
        self.getClient().usersList() { response, error in
            for (_,subJson):(String, JSON) in response {
                let user:User = User()
                user.setName(subJson["name"].stringValue)
                user.setId(subJson["id"].stringValue)
                self.connection.addUser(user)
            }
            completion(true, error)
            
        }
    }
    
}
