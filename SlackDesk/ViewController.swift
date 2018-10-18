import Cocoa

class ViewController: NSTabViewController {
    @IBOutlet var connectionTabView: NSTabView!
    
    public var connections: Array<Connection> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let connection:Connection = Connection()
        connection.setKey("***REMOVED***")
        connection.setName("Sevendays")
        
        let connection2:Connection = Connection()
        connection2.setKey("***REMOVED***")
        connection2.setName("Sevendays2")
        
        
        let connection3:Connection = Connection()
        connection3.setKey("***REMOVED***")
        connection3.setName("Sevendays3")
        
        
        self.connections.append(connection)
        self.connections.append(connection2)
        self.connections.append(connection3)

        for connection in self.connections {
            let newItem: NSTabViewItem = NSTabViewItem(identifier: connection.getName())
            newItem.label = connection.getName()
            
            let viewController = storyboard?.instantiateController(withIdentifier: "connectionDetail") as? ConnectionSplitViewController
            viewController?.setConnection(connection: connection)
            newItem.viewController = viewController
            addTabViewItem(newItem)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}
