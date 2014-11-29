//
//  resources.swift
//  CLine
//
//  Created by Ivan Moscoso on 11/28/14.
//  Copyright (c) 2014 3bx. All rights reserved.
//

import Foundation

class Resources {
    let BASE_URL = "https://apps-apis.google.com/a/feeds/calendar/resource/2.0/";

    func load() {
        
        let urlString = BASE_URL + User.currentUser().domain + "/"
        var signedReq: NXOAuth2Request
        
        let accounts = NXOAuth2AccountStore.sharedStore().accountsWithAccountType("Calendar") as NSArray
        let account = accounts.firstObject as? NXOAuth2Account

        signedReq = NXOAuth2Request(resource:NSURL(string:urlString), method:"GET", parameters:nil)
        signedReq.account = account

        let xmlRequest = signedReq.signedURLRequest().mutableCopy() as NSMutableURLRequest
        xmlRequest.addValue("application/atom+xml", forHTTPHeaderField: "Content-type")
        
        println("Sending URL: \(xmlRequest.URL?.absoluteString)")
        
        sendRequest(xmlRequest)
    }
    
    func sendRequest(xmlRequest: NSURLRequest) {
        var response: NSURLResponse?
        var error: NSErrorPointer = nil
        
        RunState.isWaitingForNetwork = true
        let data:NSData? = NSURLConnection.sendSynchronousRequest(xmlRequest, returningResponse: &response, error: error)
        if (data != nil) {
            println("Resource call received \(data?.length) bytes.")
            // <link rel='next' .*? href='{{value}}'/> suggests {{value}} is a continuation of resources
        }
        RunState.isWaitingForNetwork = false

    }
}