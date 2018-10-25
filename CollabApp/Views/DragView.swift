import Cocoa

protocol DragViewDelegate {
    func dragView(didDragFileWith URL: NSURL)
    func fileEnter()
    func fileExit()
}

class DragView: NSView {
    
    var delegate: DragViewDelegate?
    var defaultBackground: CGColor?

    // Parameter to check if file type is ok.
    private var fileTypeIsOk = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.defaultBackground = self.layer?.backgroundColor!.copy(alpha: 0.0)!
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    // Set file type ok when drag entered.
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let overlayColor: CGColor = NSColor.controlAccentColor.cgColor.copy(alpha: 0.8)!
        self.layer?.backgroundColor = overlayColor
        fileTypeIsOk = checkExtension(drag: sender)
        delegate?.fileEnter()
        return []
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = defaultBackground
        delegate?.fileExit()
    }
    
    // Keep a copy of the file.
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileTypeIsOk ? .copy : []
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let draggedFileURL = sender.draggedFileURL else {
            return false
        }
        
        //call the delegate
        if fileTypeIsOk {
            delegate?.dragView(didDragFileWith: draggedFileURL)
        }
        
        return true
    }
    
    // Check if the file extension is supported.
    fileprivate func checkExtension(drag: NSDraggingInfo) -> Bool {
        // We allow all files.
        return true
    }
    
}

extension NSDraggingInfo {
    var draggedFileURL: NSURL? {
        let filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? Array<String>
        let path = filenames?.first

        return path.map(NSURL.init)
    }
}
