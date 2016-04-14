//
//  ViewController.swift
//  app-login
//
//  Created by Jesse Pollak on 4/12/16.
//  Copyright © 2016 Clef. All rights reserved.
//

import UIKit
import WebKit


class ViewController: UIViewController {

    var clefWebView: WKWebView!
    
    let webViewDelegate = WebViewBridge()
    
    @IBOutlet weak var loggedInLabel: UILabel!
    @IBOutlet weak var logInWithClefButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupWebview()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleClefAuthenticationCallback), name: ClefAuthenticationCallback, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleClefAuthenticationVerify), name: ClefAuthenticationVerify, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleClefAuthenticationSuccess), name: ClefAuthenticationSuccess, object: nil)
    }
    
    func setupWebview() {
        let configuration = WKWebViewConfiguration()
        self.clefWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), configuration: configuration)
        self.clefWebView.navigationDelegate = self.webViewDelegate
        self.clefWebView.UIDelegate = self.webViewDelegate
        self.view.addSubview(self.clefWebView)
    }
    
    @IBAction func onClefButtonTap(sender: UIButton) {
        let url = NSURL(string: ServerHost + "/clef/start")!
        self.clefWebView.loadRequest(NSURLRequest(URL: url))
    }
    
    func handleClefAuthenticationCallback(notification: NSNotification) {
        let callbackURL = notification.userInfo!["url"] as! NSURL
        let url = NSURL(string: ServerHost +  "/clef/callback?" + callbackURL.query!)!
        self.clefWebView.loadRequest(NSURLRequest(URL: url))
    }
    
    func handleClefAuthenticationVerify(notification: NSNotification) {
        let verifyURL = notification.userInfo!["url"] as! NSURL
        let url = NSURL(string: ServerHost +  "/clef/verify?" + verifyURL.query!)!
        self.clefWebView.loadRequest(NSURLRequest(URL: url))
    }
    
    func handleClefAuthenticationSuccess(notification: NSNotification) {
        self.clefWebView.removeFromSuperview()
        self.logInWithClefButton.hidden = true
        
        let userInformation = notification.userInfo as! [String:AnyObject]
        self.loggedInLabel.text = String(format: "You are logged in with the clef ID: %d", userInformation["id"] as! Int)
        self.loggedInLabel.hidden = false
    }
}