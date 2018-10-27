import Foundation

// This is the initial step to the notification manager.
// It should be easy to, at some point, implement settings or use those from the slack
// application.
class NotificationManager {
    
    private var connection: Connection
    
    init(connection: Connection) {
        self.connection = connection
    }
    
    public func showNotificationForMessageAndChannel(message: Message, channel: Channel) -> Void {
        self.showNotificationWithTitleAndBody("New message in " + channel.getName(),message.getBody().value)
    }
    
    public func showNotificationForNewChannel(channel: Channel) -> Void {
        self.showNotificationWithTitleAndBody("New channel", "The channel " + channel.getName() + " has been added")
    }
    
    private func showNotificationWithTitleAndBody(_ title: String, _ body: String) -> Void {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
}
