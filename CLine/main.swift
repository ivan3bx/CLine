//
//  main.swift
//  CLine
//
//  Created by Ivan Moscoso on 11/23/14.
//  Copyright (c) 2014 3bx. All rights reserved.
//

import Foundation

struct RunState {
    static var isRunning:           Bool = true
    static var isWaitingForNetwork: Bool = false
}

class Main {
    let runLoop = NSRunLoop.currentRunLoop()

    let prompt: Input = Input()
    var auth: Authentication
    
    init() {
        let data: NSData! = NSData(contentsOfFile: "/Users/ivan/projects/CLine/CLine/clientConfig.json")
        let dict: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)!
        auth = Authentication(config: dict["installed"] as NSDictionary)
    }
    
    func run() {
        if (!auth.isAuthorized()) {
            auth.authenticate()
        }
        
        while (RunState.isRunning && runLoopOnce()) {
            if (!RunState.isWaitingForNetwork) {
                /* No network requests active so get a command */
                blockThreadForInput()
            }
        }

        
        // No more input
        println("\nExiting.")
        RunState.isRunning = false
    }
    
    func runLoopOnce() -> Bool {
        print(".")
        return runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 2.0))
    }
    
    /*
    ** Delegate and process a command
    */
    func processCommand(line: NSArray) {
        User.currentUser().load()
        Resources().load()
    }
    
    /*
    ** blocking call to accept input
    */
    func blockThreadForInput() {
        var line = prompt.read()
        processCommand(line)
    }
}

Main().run()
