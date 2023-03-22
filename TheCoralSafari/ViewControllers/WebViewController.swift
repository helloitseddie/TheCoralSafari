//
//  SecondViewController.swift
//  TheCoralSafari
//
//  Created by Kat Reiz on 3/16/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var faq: FAQ!
    var faqs: [FAQ] = []
    
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        
        guard let url = URL(string: faq.path) else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
}
