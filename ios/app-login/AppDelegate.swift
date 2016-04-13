//
//  AppDelegate.swift
//  app-login
//
//  Created by Jesse Pollak on 4/12/16.
//  Copyright © 2016 Clef. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if let host = url.host {
            if (host == "clef") {
                let components = url.pathComponents!
                let name: String
                
                switch (components[1]) {
                case "callback":
                    name = ClefAuthenticationCallback
                    break
                case "verify":
                    name = ClefAuthenticationVerify
                    break
                default:
                    return true
                }
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(
                    name: name,
                    object: self,
                    userInfo: [
                        "url": url
                    ]
                ))
            }
        }
        
        return true
    }
}

