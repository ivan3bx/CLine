//
//  authentication.swift
//  CLine
//
//  Created by Ivan Moscoso on 11/23/14.
//  Copyright (c) 2014 3bx. All rights reserved.
//

import Foundation
import WebKit

class Authentication {

    let scope = NSSet(objects:
        "https://www.googleapis.com/auth/calendar",
        "https://apps-apis.google.com/a/feeds/calendar/resource/",
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/userinfo.profile"
    )
    
    private var account: NXOAuth2Account?
    
    func isAuthorized() -> Bool {
        return (account != nil)
    }
    
    init(config: NSDictionary) {
        let clientId      : NSString = config["client_id"] as NSString
        let secret        : NSString = config["client_secret"] as NSString
        let keyChainGroup : NSString = "CLine"
        let accountType   : NSString = "Calendar"
        let authURL       : NSURL = NSURL(string: (config["auth_uri"] as NSString))!
        let tokenURL      : NSURL = NSURL(string: (config["token_uri"] as NSString))!
        let redirectURL   : NSURL = NSURL(string: "http://localhost:7777/oauth.callback")!
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserverForName(NXOAuth2AccountStoreAccountsDidChangeNotification,
            object: NXOAuth2AccountStore.sharedStore(), queue: nil) { notification in
                self.account = ((notification.userInfo as NSDictionary!)[NXOAuth2AccountStoreNewAccountUserInfoKey] as NXOAuth2Account)
                    
                
                if (self.account == nil) {
                    // Logout!
                    println("Account logged out")
                } else {
                    // Authorization!
                    println("Registered.  Token expires at: \(self.account?.accessToken.expiresAt)")
                }

                /* Signal that we're done with the network after this run loop */
                RunState.isWaitingForNetwork = false
        }
        
        center.addObserverForName(NXOAuth2AccountStoreDidFailToRequestAccessNotification,
            object: NXOAuth2AccountStore.sharedStore(), queue: nil) { notification in
                println("Notified of failed request")

                /* Signal that we're done with the network after this run loop */
                RunState.isWaitingForNetwork = false

        }

        NXOAuth2AccountStore.sharedStore().setClientID(clientId,
            secret: secret,
            scope: scope,
            authorizationURL: authURL, tokenURL: tokenURL, redirectURL: redirectURL,
            keyChainGroup: keyChainGroup, forAccountType: accountType)

        let accounts = NXOAuth2AccountStore.sharedStore().accountsWithAccountType("Calendar") as NSArray
        self.account = accounts.firstObject as? NXOAuth2Account

    }
    
    func authenticate() {

        /* Signal that we'll be waiting for network after this run loop */
        RunState.isWaitingForNetwork = true
        
        let webServer   = startWebServer()
        NXOAuth2AccountStore.sharedStore().requestAccessToAccountWithType("Calendar")
    }
    
    func startWebServer() -> GCDWebServer {
        let webServer = GCDWebServer()
        
        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.self, processBlock: { request in

            if (request.query["error"] != nil) {
                //
                // Will receive "?error=access_denied" on 'cancel' or fail
                //
                println("OAuth failed.  Quitting.")
                webServer.stop()
                RunState.isRunning = false
            } else if (request.path.rangeOfString("oauth.callback") != nil) {
                //
                // Successful OAuth attempt; delegate to NXOAuth2 in Main Thread
                //
                println("Delegating to NXOAuth2 [query: \(request.query)")
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    NXOAuth2AccountStore.sharedStore().handleRedirectURL(request.URL)
                    return
                }
                
                
            }
            return GCDWebServerResponse(statusCode: 200)
        })
        webServer.startWithPort(7777, bonjourName: nil)
        println("Started server at \(webServer.serverURL)")
        
        return webServer
    }
    
}


