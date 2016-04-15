//
//  ClefAuthentication.swift
//  app-login
//
//  Created by Jesse Pollak on 4/12/16.
//  Copyright © 2016 Clef. All rights reserved.
//

import UIKit
import WebKit


struct ClefAuthenticationEvent {
    static let Callback = "clef.callback"
    static let Verify = "clef.verify"
    static let Success = "clef.success"
}

class Clef : NSObject {
    static let sharedInstance = Clef()
    
    var authenticationWebView: WKWebView?
    var authenticationWebViewDelegate: ClefWKWebViewDelegate?
    var onSuccess: ((data: [String:AnyObject]?) -> Void)?
    
    var configured: Bool = false
    var startURL: NSURL!
    var callbackURL: NSURL!
    var verifyURL: NSURL?
    var isDistributedAuth: Bool = false
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleCallback), name: ClefAuthenticationEvent.Callback, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleVerify), name: ClefAuthenticationEvent.Verify, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleSuccess), name: ClefAuthenticationEvent.Success, object: nil)
    }
    
    func configure(startURL startURL: NSURL, callbackURL: NSURL, verifyURL: NSURL? = nil) {
        self.configured = true
        self.startURL = startURL
        self.callbackURL = callbackURL
        self.verifyURL = verifyURL
        self.isDistributedAuth = self.verifyURL != nil
        self.authenticationWebViewDelegate = ClefWKWebViewDelegate(isDistributedAuth: self.isDistributedAuth)
    }
    
    func handleDeepLink(openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Void {
        if let host = url.host {
            if (host == "clef") {
                let components = url.pathComponents!
                let name: String
                
                switch (components[1]) {
                case "callback":
                    name = ClefAuthenticationEvent.Callback
                    break
                case "verify":
                    name = ClefAuthenticationEvent.Verify
                    break
                default:
                    return
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
    }
    
    func startAuthentication(view: UIView, onSuccess: (data: [String:AnyObject]?) -> Void) {
        if (!self.configured) {
            print("Please configure the Clef library before calling startAuthentication")
            return
        }
        
        let configuration = WKWebViewConfiguration()
        let authenticationWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), configuration: configuration)
        
        authenticationWebView.navigationDelegate = self.authenticationWebViewDelegate
        authenticationWebView.UIDelegate = self.authenticationWebViewDelegate
        
        authenticationWebView.loadRequest(NSURLRequest(URL: self.startURL))
        
        self.authenticationWebView = authenticationWebView
        self.onSuccess = onSuccess
    }
    
    func handleCallback(notification: NSNotification) {
        if let authenticationWebView = self.authenticationWebView {
            authenticationWebView.loadRequest(NSURLRequest(URL: self.mergeURLs(self.callbackURL, urlToTakeQueryFrom: notification.userInfo!["url"] as! NSURL)))
        }
    }
    
    func handleVerify(notification: NSNotification) {
        if let authenticationWebView = self.authenticationWebView {
            authenticationWebView.loadRequest(NSURLRequest(URL: self.mergeURLs(self.verifyURL!, urlToTakeQueryFrom: notification.userInfo!["url"] as! NSURL)))
        }
    }
    
    func handleSuccess(notification: NSNotification) {
        if let authenticationWebView = self.authenticationWebView {
            authenticationWebView.removeFromSuperview()
            if let onSuccess = self.onSuccess {
                var data: [String: AnyObject]?
                if let maybeData = notification.userInfo as? [String:AnyObject] {
                    data = maybeData
                }
                onSuccess(data: data)
            }
        }
    }
    
    private func mergeURLs(base: NSURL, urlToTakeQueryFrom: NSURL) -> NSURL {
        let baseComponents = NSURLComponents(URL: base, resolvingAgainstBaseURL: false)!
        let urlToTakeQueryFromComponents = NSURLComponents(URL: urlToTakeQueryFrom, resolvingAgainstBaseURL: false)
        let mergedQueryItems: [NSURLQueryItem]?
        
        if let baseQueryItems = baseComponents.queryItems {
            if let urlToTakeQueryFromQueryItems = urlToTakeQueryFromComponents?.queryItems {
                mergedQueryItems = baseQueryItems + urlToTakeQueryFromQueryItems
            } else {
                mergedQueryItems = baseQueryItems
            }
        } else {
            mergedQueryItems = urlToTakeQueryFromComponents?.queryItems
        }
        
        let mergedComponents = baseComponents
        mergedComponents.queryItems = mergedQueryItems
        return mergedComponents.URL!
    }
}

class ClefWKWebViewDelegate : NSObject, WKNavigationDelegate, WKUIDelegate {
    var isDistributedAuth: Bool!
    
    init(isDistributedAuth: Bool = false) {
        super.init()
        self.isDistributedAuth = isDistributedAuth
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.navigationType == WKNavigationType.Other) {
            let url = navigationAction.request.URL!
            
            if (url.scheme == "message") {
                if let message = self.processEncodedMessage(url.host!) {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(
                        name: ClefAuthenticationEvent.Success,
                        object: self,
                        userInfo: message
                    ))
                }
                
                return decisionHandler(WKNavigationActionPolicy.Cancel)
            }
            
            if (url.scheme == "clef" || (self.isDistributedAuth && url.host! == "clef.io")) {
                UIApplication.sharedApplication().openURL(url)
                return decisionHandler(WKNavigationActionPolicy.Cancel)
            }
        }
        
        return decisionHandler(WKNavigationActionPolicy.Allow)
    }

    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        return completionHandler()
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        return completionHandler(true)
    }
    
    func processEncodedMessage(message: String) -> [String:AnyObject]? {
        let data: NSData = NSData(base64EncodedString: message, options: NSDataBase64DecodingOptions(rawValue: 0))!
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String:AnyObject]
        } catch {
            return nil
        }
    }
}