//
//  InfoVC.swift
//  beacon
//
//  Created by Admin on 6/8/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class InfoVC: BaseVC {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblNoInternet: UILabel!
    
    override func viewDidLoad() {
      
    }
    
    override func viewDidAppear(_ animated: Bool) {        
        if Common.isInternetAvailable {
            webView.isHidden = false
            lblNoInternet.isHidden = true
            
            webView.loadRequest(NSURLRequest(url: NSURL(string: "http://hazm.tech/mobile/app/ios/info.html")! as URL) as URLRequest)
            webView.reload()
        }else{
            webView.isHidden = true
            lblNoInternet.isHidden = false
        }
    }
}
