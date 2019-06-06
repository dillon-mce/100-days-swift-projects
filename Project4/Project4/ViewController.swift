//
//  ViewController.swift
//  Project4
//
//  Created by Dillon McElhinney on 6/6/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!

    override func loadView() {
        // Change the default view to be a WKWebView
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Open",
                            style: .plain,
                            target: self,
                            action: #selector(openTapped))
        
        // Load a default website
        let url = URL(string: "https://dillon-mce.com")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }


    @objc func openTapped() {
        // Make the controller
        let ac = UIAlertController(title: "Open page...",
                                   message: nil,
                                   preferredStyle: .actionSheet)
        
        // Make the actions
        let appleAction = UIAlertAction(title: "apple.com",
                                        style: .default,
                                        handler: openPage)
        
        let blogAction = UIAlertAction(title: "dillon-mce.com",
                                       style: .default,
                                       handler: openPage)
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        // Configure the controller
        ac.addAction(appleAction)
        ac.addAction(blogAction)
        ac.addAction(cancelAction)
        ac.popoverPresentationController?.barButtonItem =
            self.navigationItem.rightBarButtonItem
        
        // Present it
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        let url = URL(string: "https://" + action.title!)!
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}

