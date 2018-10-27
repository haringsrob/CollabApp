import Foundation
import RxSwift

class Message {
    
    private var body:Variable<String> = Variable("");
    private var timeStamp:String = "";
    private var userId:String = "";
    
    public func setBody(_ body: String) -> Void {
        self.body.value = body;
    }

    public func getBody() -> Variable<String> {
        return self.body;
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
