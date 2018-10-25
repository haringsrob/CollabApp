enum ChannelException: Error {
    case ChannelWithIdNotFound(id: String)
    case userWithIdNotFound(id: String)
}
