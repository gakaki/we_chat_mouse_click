//
//  ViewController.swift
//  MouseClick
//
//  Created by g on 16/9/30.
//  Copyright © 2016年 g. All rights reserved.
//

import Cocoa

open class GlobalEventMonitor {
    
    fileprivate var monitor: AnyObject?
    fileprivate let mask: NSEventMask
    fileprivate let handler: (NSEvent?) -> ()
    
    public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    open func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject?
    }
    
    open func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
class ViewController: NSViewController {

    var eventHandler : GlobalEventMonitor?
    var eventHandlerClick : GlobalEventMonitor?
    var eventHandlerKey : GlobalEventMonitor?

    
    @IBOutlet weak var txt_x: NSTextField!
    @IBOutlet weak var txt_y: NSTextField!
    
    var loc:CGPoint!
    var loc_current:CGPoint!
    
    func getMousePos() -> CGPoint {
        let m = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,  mouseCursorPosition: self.loc, mouseButton: .left)
        let p = m?.location
        print(p)
        return p!
    }
    func getPosTopLeft(_ pos:CGPoint) -> CGPoint {
        let p = CGPoint(x: pos.x, y: abs(pos.y + -NSScreen.main()!.frame.height))
        return p
        //                let p = CGPoint(x: l.x, y: abs(l.y + -NSScreen.mainScreen()!.visibleFrame.height))

    }
    func mouseToPos(_ pos:CGPoint){
        let e   = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,  mouseCursorPosition: pos , mouseButton: .left)
        e?.type = CGEventType.mouseMoved
        e?.post(tap: .cghidEventTap)
    }
    
    func mouseToPosQS(_ pos:CGPoint){
        let displayID       = CGMainDisplayID()
        let screenWidth     = CGDisplayPixelsWide(displayID)
        let screenHeight    = CGDisplayPixelsHigh(displayID)
        let centerOfScreen  = CGPoint( x: CGFloat(screenWidth / 2), y: CGFloat(screenHeight / 2))
        CGWarpMouseCursorPosition(centerOfScreen)
        CGWarpMouseCursorPosition(pos)
    }
    
    func triggerMouseClick(_ pos:CGPoint){
        let click1_down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: pos, mouseButton: .left)
        let click1_up   = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: pos, mouseButton: .left)
        
        click1_down?.post(tap: .cghidEventTap)
        click1_up?.post(tap: .cghidEventTap)
        click1_down?.post(tap: .cghidEventTap)
        click1_up?.post(tap: .cghidEventTap)
    }
    
    func seTxt(_ p:CGPoint){
        
        self.txt_x.stringValue = String(describing: p.x)
        self.txt_y.stringValue = String(describing: p.y)
        
        let b = "x : \(p.x) , y:  \(p.y)"
        print(b)

    }
    @IBAction func reclick(_ sender: AnyObject?) {
        if let loc = self.loc {
            self.mouseToPos(loc)
            self.triggerMouseClick(loc)
        }
     
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSApplication.shared().mainWindow?.windowController?.window?.acceptsMouseMovedEvents
            = true
        
        eventHandlerKey = GlobalEventMonitor(mask: .keyUp, handler: { (e: NSEvent?) in
            
            print(e!.keyCode)
            print(e!.modifierFlags)
            
            
            let keyCode      = e!.keyCode
            let modifyFlags  = e!.modifierFlags
            if keyCode == 1 && modifyFlags.rawValue == 1048840 {
                
                self.loc_current = self.getPosTopLeft(self.mouseLocation)
                self.reclick(nil)
                self.mouseToPos(self.loc_current)
            }
           
        })
        
        eventHandler = GlobalEventMonitor(mask: .mouseMoved, handler: { (mouseEvent: NSEvent?) in
            
            print(mouseEvent?.absoluteX,mouseEvent?.absoluteY,mouseEvent?.locationInWindow)
            
            print(self.view.convert((mouseEvent?.locationInWindow)!,from:nil))
            
            
        })
        
        eventHandlerClick = GlobalEventMonitor(mask: .rightMouseDown, handler: { (mouseEvent: NSEvent?) in
            
            self.loc = nil
            
            
//            let window = NSApplication.sharedApplication().mainWindow?.windowController?.window
            
//            let l = self.view.convertPoint((mouseEvent?.locationInWindow)!, fromView: self.view)

            if let l = mouseEvent?.locationInWindow {
            
                self.loc = self.getPosTopLeft(l)
                self.seTxt( self.loc)
                print(self.getMousePos())
                
            }
            
            
        })

        
        eventHandlerClick?.start()
        eventHandler?.start()
        eventHandlerKey?.start()
    }

    

    var mouseLocation: NSPoint {
        return NSEvent.mouseLocation()
    }
    override func mouseMoved(with theEvent: NSEvent) {
        print( "Mouse Location X,Y = \(mouseLocation)" )
        print( "Mouse Location X = \(mouseLocation.x)" )
        print( "Mouse Location Y = \(mouseLocation.y)" )
    }
}

