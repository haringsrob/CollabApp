enum ChannelException: Error {
    case ChannelWithIdNotFound(id: String)
    case userWithIdNotFound(id: String)
    case messageWithTsNotFound(ts: String)
}
