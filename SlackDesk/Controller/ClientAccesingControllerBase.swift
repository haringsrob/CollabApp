import Foundation

/**
 * A basic controller to be used for data fetching controllers.
 */
class ClientAccesingControllerBase {
    
    public var client: SlackClient?;
    
    public var connection:Connection;
    
    init(connection: Connection) {
        self.connection = connection;
    }
    
    public func getClient()-> SlackClient {
        if (nil == self.client) {
            self.client = SlackClient(apiKey: self.connection.getKey())
        }
        return self.client!
    }
    
}
