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
    
    @IBOutlet weak var loggedInLabel: UILabel!
    @IBOutlet weak var logInWithClefButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func onClefButtonTap(sender: UIButton) {
        Clef.sharedInstance.startAuthentication(self.view, onSuccess: self.handleClefAuthenticationSuccess)
    }
    
    func handleClefAuthenticationSuccess(data: [String:AnyObject]?) {
        self.logInWithClefButton.hidden = true
        self.loggedInLabel.text = String(format: "You are logged in with the clef ID: %d", data!["id"] as! Int)
        self.loggedInLabel.hidden = false
    }
}