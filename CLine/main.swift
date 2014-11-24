//
//  main.swift
//  CLine
//
//  Created by Ivan Moscoso on 11/23/14.
//  Copyright (c) 2014 3bx. All rights reserved.
//

import Foundation

struct RunState {
    static var isRunning: Bool = true
}

class Main {
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
    }
}

let runLoop = NSRunLoop.currentRunLoop()
Main().run()

while (RunState.isRunning && runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 2))) {
    println(".")
}
