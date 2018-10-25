import Cocoa
import Smile
import Down
import Regex

class ViewController: NSTabViewController {
    @IBOutlet var connectionTabView: NSTabView!
    
    public var connections: Array<Connection> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let connection:Connection = Connection()
        connection.setKey("***REMOVED***")
        connection.setName("Harings.be")
        
        self.connections.append(connection)

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

func replaceLinksAndGetAttributedString(_ text: String, connection: Connection) -> NSAttributedString {
    var emojiText = Smile.replaceAlias(string: text);
    
    emojiText = ("<@([A-Z]\\w+){1}(\\|.+)?>".r?.replaceAll(in: emojiText) { match in
        if match.group(at: 1) != nil {
            do {
                return try "<@" + (connection.findUserById(match.group(at: 1)!).getName()) + ">"
            }
            catch {
                return nil
            }
        }
        return nil
    })!
    
    let down = Down(markdownString: emojiText)
    let InMutableAttributedString = try? down.toAttributedString()
    
    let attributedString: NSMutableAttributedString = InMutableAttributedString?.mutableCopy() as! NSMutableAttributedString
    
    // Trim the last linebreak.
    if (attributedString.string.last == "\n") {
        attributedString.deleteCharacters(in: NSRange(location: attributedString.length-1, length: 1))
    }
    
    // Fix the string to be system coloured.
    attributedString.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, attributedString.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (value, range, stop) in
        let color:NSColor = NSColor(catalogName: "System", colorName: "textColor")!
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
    return attributedString
}
