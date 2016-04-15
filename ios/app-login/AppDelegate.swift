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
        Clef.sharedInstance.configure(
            startURL: NSURL(string: "http://localhost:8080/clef/start")!,
            callbackURL: NSURL(string: "http://localhost:8080/clef/callback")!,
            verifyURL: NSURL(string: "http://localhost:8080/clef/verify")!
        )
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        Clef.sharedInstance.handleDeepLink(openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        return true
    }
}

