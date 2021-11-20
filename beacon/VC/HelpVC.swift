//
//  HelpVC.swift
//  beacon
//
//  Created by Admin on 6/8/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit

class HelpVC: BaseVC {
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var lblNoInternet: UILabel!
    
    override func viewDidLoad() {        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Help OK")
        if Common.isInternetAvailable {
            webView.isHidden = false
            lblNoInternet.isHidden = true
            
            webView.loadRequest(NSURLRequest(url: NSURL(string: "http://hazm.tech/mobile/app/ios/help.html")! as URL) as URLRequest)
            webView.reload()
            let scrollableSize = CGSize(width: view.frame.size.width, height: webView.scrollView.contentSize.height)
            webView.scrollView.contentSize = scrollableSize
            webView.scrollView.isScrollEnabled = true
            webView.scrollView.showsHorizontalScrollIndicator = true
        }else{
            webView.isHidden = true
            lblNoInternet.isHidden = false
        }
        
    }
}
