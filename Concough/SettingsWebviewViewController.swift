//
//  SettingsWebviewViewController.swift
//  Concough
//
//  Created by Owner on 2017-02-03.
//  Copyright © 2017 Famba. All rights reserved.
//

import UIKit

class SettingsWebviewViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    
    internal var loadingAddress: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        self.webview.loadRequest(NSURLRequest(URL: NSURL(string: self.loadingAddress)!))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
}
