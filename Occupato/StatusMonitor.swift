//
//  StatusMonitor.swift
//  Occupato
//
//  Created by Lorenzo Gentile on 2015-08-22.
//  Copyright (c) 2015 Axiom Zen. All rights reserved.
//

import Foundation

protocol StatusMonitorDelegate: class {
    func roomStatusDidChange(room: Room, isOpen: Bool)
}

class StatusMonitor: NSObject {
    private let timeInterval = 2.0
    weak var delegate: StatusMonitorDelegate? = nil
    var mensIsOpen: Bool = true {
        didSet(prev) {
            if mensIsOpen != prev {
                delegate?.roomStatusDidChange(.Mens, isOpen: mensIsOpen)
            }
        }
    }
    var womensIsOpen: Bool = true {
        didSet(prev) {
            if  womensIsOpen != prev {
                delegate?.roomStatusDidChange(.Womens, isOpen: womensIsOpen)
            }
        }
    }
    var showerIsOpen: Bool = true {
        didSet(prev) {
            if showerIsOpen != prev {
                delegate?.roomStatusDidChange(.Shower, isOpen: showerIsOpen)
            }
        }
    }
    
    init(delegate: StatusMonitorDelegate) {
        self.delegate = delegate
    }
    
    func startObserving() {
        getStatuses()
        let timer = NSTimer(timeInterval: timeInterval, target: self, selector: Selector("getStatuses"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    // Has to be internal for the timer to call it
    func getStatuses() {
        if let url = NSURL(string: "http://agile-atoll-9140.herokuapp.com/ascii/getupdate") {
            NSURLSession.sharedSession().dataTaskWithURL(url) { data, response, error in
                if let data = data, string = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                    self.updateBoolsForInput(string)
                }
            }.resume()
        }
    }
    
    private func updateBoolsForInput(string: String) {
        let chars = string.characters
        if let mensIndex = chars.indexOf("1")?.successor(), womensIndex = chars.indexOf("2")?.successor(), showerIndex = chars.indexOf("3")?.successor() {
            if let mens = boolForChar(chars[mensIndex]), womens = boolForChar(chars[womensIndex]), shower = boolForChar(chars[showerIndex]) {
                mensIsOpen = mens
                womensIsOpen = womens
                showerIsOpen = shower
            }
        }
    }
    
    private func boolForChar(char: Character) -> Bool? {
        if char == "t" { return true }
        if char == "f" { return false }
        return nil
    }
}
