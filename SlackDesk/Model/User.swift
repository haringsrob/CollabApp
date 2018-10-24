import Foundation
import RxSwift

class User: baseIdNameModel, UserProtocol {
    public var isConnected:Variable<Bool> = Variable(false)
}
