import Foundation

class Message: MessageProtocol {
    
    private var body:String = "";
    private var timeStamp:String = "";
    private var userId:String = "";
    
    private var bodyAttributedString:NSAttributedString?

    public func setBody(_ body: String) -> Void {
        self.body = body;
    }
    
    public func getBody(connection: Connection) -> NSAttributedString {
        if self.bodyAttributedString == nil {
            self.bodyAttributedString = replaceLinksAndGetAttributedString(self.body, connection: connection)
        }
        
        return self.bodyAttributedString!;
    }

    public func setTimeStamp(_ timeStamp: String) -> Void {
        self.timeStamp = timeStamp;
    }

    public func getTimeStamp() -> String {
        return self.timeStamp;
    }

    public func setUserId(_ userId: String) -> Void {
        self.userId = userId;
    }

    public func getUserId() -> String {
        return self.userId;
    }

}
