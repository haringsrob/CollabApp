import Foundation

class baseIdNameModel: baseIdNameModelProtocol {
    
    private var name:String = "";
    private var id:String = "";
    
    public func setName(_ name: String) -> Void {
        self.name = name;
    }
    
    public func getName() -> String {
        return self.name;
    }
    
    public func setId(_ id: String) -> Void {
        self.id = id;
    }
    
    public func getId() -> String {
        return self.id;
    }
}
