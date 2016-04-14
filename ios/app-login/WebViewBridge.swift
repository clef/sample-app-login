//
//  WebViewBridge.swift
//  app-login
//
//  Created by Jesse Pollak on 4/12/16.
//  Copyright © 2016 Clef. All rights reserved.
//

import UIKit
import WebKit



class WebViewBridge : NSObject, WKNavigationDelegate, WKUIDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        let type = navigationAction.navigationType
        if (type == WKNavigationType.Other) {
            let url = navigationAction.request.URL!
            
            if (url.scheme == "message") {
                if let message = self.processEncodedMessage(url.host!) {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(
                        name: ClefAuthenticationSuccess,
                        object: self,
                        userInfo: message
                        ))
                }
                
                return decisionHandler(WKNavigationActionPolicy.Cancel)
            }
            
            if (url.scheme == "clef" || url.host! == "clef.io") {
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