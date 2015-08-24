//
//  AppDelegate.swift
//  Occupato
//
//  Created by Lorenzo Gentile on 2015-08-22.
//  Copyright (c) 2015 Axiom Zen. All rights reserved.
//

import Cocoa

enum Room {
    case Mens
    case Womens
    case Shower
    
    var description: String {
        switch self {
        case Mens: return "Men's washroom"
        case Womens: return "Women's washroom"
        case Shower: return "Shower room"
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, StatusMonitorDelegate {
    private let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    private var statusMonitor: StatusMonitor?
    private let mensMenuItem = NSMenuItem(title: "Men's Washroom", action: Selector("mensPressed"), keyEquivalent: "")
    private let womensMenuItem = NSMenuItem(title: "Women's Washroom", action: Selector("womensPressed"), keyEquivalent: "")
    private let showerMenuItem = NSMenuItem(title: "Shower Room", action: Selector("showerPressed"), keyEquivalent: "")
    private let notifyMenuItem = NSMenuItem(title: "Notify me", action: Selector("notifyPressed"), keyEquivalent: "")
    private let menu = NSMenu()
    private var notify = false {
        didSet {
            notifyMenuItem.state = notify ? NSOnState : NSOffState
        }
    }
    private var room: Room = .Mens {
        didSet {
            mensMenuItem.state = room == .Mens ? NSOnState : NSOffState
            womensMenuItem.state = room == .Womens ? NSOnState : NSOffState
            showerMenuItem.state = room == .Shower ? NSOnState : NSOffState
            updateIconForRoom(room)
        }
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        configureMenu()
        room = .Mens
        
        statusItem.button?.image = NSImage(named: "openIcon")
        statusItem.menu = menu
        
        statusMonitor = StatusMonitor(delegate: self)
        statusMonitor?.startObserving()
    }
    
    private func configureMenu() {
        menu.addItem(mensMenuItem)
        menu.addItem(womensMenuItem)
        menu.addItem(showerMenuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(notifyMenuItem)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: ""))
    }
    
    private func showRoomAvailableNotification(room: Room) {
        let notification = NSUserNotification()
        notification.title = "Occupato"
        notification.informativeText = "\(room.description) is available"
        notification.soundName = NSUserNotificationDefaultSoundName
        
        let notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        notificationCenter.delegate = self
        notificationCenter.deliverNotification(notification)
    }
    
    private func updateIconForRoom(room: Room) {
        let isOpen: Bool?
        switch room {
        case .Mens: isOpen = statusMonitor?.mensIsOpen
        case .Womens: isOpen = statusMonitor?.womensIsOpen
        case .Shower: isOpen = statusMonitor?.showerIsOpen
        }
        if let isOpen = isOpen {
            statusItem.button?.image = NSImage(named: isOpen ? "openIcon" : "closedIcon")
        }
    }
    
    // MARK: Menu Item Handlers
    
    func mensPressed() {
        room = .Mens
    }
    
    func womensPressed() {
        room = .Womens
    }
    
    func showerPressed() {
        room = .Shower
    }
    
    func notifyPressed() {
        notify = !notify
    }
    
    // MARK: NSUserNotificationCenterDelegate

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    // MARK: StatusMonitorDelegate
    
    func roomStatusDidChange(room: Room, isOpen: Bool) {
        if self.room == room {
            if isOpen && notify {
                showRoomAvailableNotification(room)
                notify = false
            }
            updateIconForRoom(room)
        }
    }
}
