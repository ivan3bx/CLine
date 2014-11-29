//
//  User.swift
//  CLine
//
//  Created by Ivan Moscoso on 11/29/14.
//  Copyright (c) 2014 3bx. All rights reserved.
//

import Foundation

class User {
    var domain:String    = ""
    var firstName:String = ""
    var lastName:String  = ""
    var email:String     = ""
    var rawData:String   = ""
    
    private struct UserData {
        static var currentUser:User = User()
    }
    
    class func currentUser() -> User {
        return UserData.currentUser
    }
    
    func load() {
        let BASE_URL = "https://www.googleapis.com/plus/v1/people/me"
        
        var signedReq: NXOAuth2Request
        
        let accounts = NXOAuth2AccountStore.sharedStore().accountsWithAccountType("Calendar") as NSArray
        let account = accounts.firstObject as? NXOAuth2Account
        
        signedReq = NXOAuth2Request(resource:NSURL(string:BASE_URL), method:"GET", parameters:nil)
        signedReq.account = account
        
        processRequest(signedReq.signedURLRequest())
    }
    
    func processRequest(request: NSURLRequest) {
        var response: NSURLResponse?
        var error: NSErrorPointer = nil
        
        RunState.isWaitingForNetwork = true
        println("Sending URL: \(request.URL.absoluteString)")
        let data:NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: error)
        if (data != nil) {
            parseResponse(data!)
        }
        RunState.isWaitingForNetwork = false
    }
    
    func parseResponse(data:NSData) {
        var error:NSErrorPointer = nil
        UserData.currentUser.rawData = NSString(data: data, encoding: NSUTF8StringEncoding)!
        
        let dict:NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: error) as NSDictionary?
        if (dict != nil) {
            let name = dict!["name"] as NSDictionary
            let emails = dict!["emails"] as NSArray
            let emailEntry = emails.firstObject as NSDictionary

            UserData.currentUser.domain = dict!["domain"] as String
            UserData.currentUser.firstName = name["givenName"] as String
            UserData.currentUser.lastName  = name["familyName"] as String
            UserData.currentUser.email = emailEntry["value"] as String
        }
        println("Resource call received \(data.length) bytes.")

    }
}