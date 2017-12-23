//
//  WebViewController.swift
//  MiniInstagram
//
//  Created by Renu Punjabi on 12/10/17.
//  Copyright © 2017 Renu Punjabi. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift

typealias WebView = UIWebView

class WebViewController: OAuthWebViewController {

    var targetURL: URL?
    let webView: WebView = WebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.frame = UIScreen.main.bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()
    }
    
    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        self.loadAddressURL()
    }
    
    func loadAddressURL() {
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
        self.webView.loadRequest(req)
    }
}


// MARK: delegate
    // todo renu - edit handling and dismiss webviewcontroller
    extension WebViewController: UIWebViewDelegate {
        func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
            #if DEBUG
                print("BEFORE URL REQ  = \(request)")
            #endif
            let url = request.url
            let urlString = url?.absoluteString
            if (urlString?.hasPrefix("https://www.23andme.com/"))! {
                OAuthSwift.handle(url: url!)
                self.dismissWebViewController()
            }
            return true
        }
}
