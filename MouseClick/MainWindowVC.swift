

import Cocoa

class MainWindowVC: NSWindowController {
    var mouseLocation: NSPoint {
        return NSEvent.mouseLocation()
    }
    override func mouseMoved(with theEvent: NSEvent) {
        print( "Mouse Location X,Y = \(mouseLocation)" )
        print( "Mouse Location X = \(mouseLocation.x)" )
        print( "Mouse Location Y = \(mouseLocation.y)" )
    }
}
