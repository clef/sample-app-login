//
//  WebViewBridge.swift
//  app-login
//
//  Created by Jesse Pollak on 4/12/16.
//  Copyright © 2016 Clef. All rights reserved.
//

import UIKit

class WebViewBridge : NSObject, UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if (navigationType == UIWebViewNavigationType.Other) {
            let url = request.URL!
            if (url.scheme == "message") {
                if let message = self.processEncodedMessage(url.host!) {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(
                        name: ClefAuthenticationSuccess,
                        object: self,
                        userInfo: message
                        ))
                }
                
                return false
            }
        }
        
        return true
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