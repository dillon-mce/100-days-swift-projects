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
    var progressView: UIProgressView!
    var websites = ["dillon-mce.com", "apple.com"]

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
        
        // Set up the toolbar
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        let spacer =
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                     target: nil,
                                     action: nil)
        let refresh =
            UIBarButtonItem(barButtonSystemItem: .refresh,
                            target: webView,
                            action: #selector(webView.reload))

        toolbarItems = [progressButton, spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        let keyPath =
            #keyPath(WKWebView.estimatedProgress)
        webView.addObserver(self,
                            forKeyPath: keyPath,
                            options: .new,
                            context: nil)
        
        // Load a default website
        let url = URL(string: "https://" + websites[0])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

    @objc func openTapped() {
        // Make the controller
        let ac = UIAlertController(title: "Open page...",
                                   message: nil,
                                   preferredStyle: .actionSheet)
        
        // Make the actions
        for website in websites {
            let action = UIAlertAction(title: website,
                                       style: .default,
                                       handler: openPage)
            ac.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        ac.addAction(cancelAction)
        
        // Configure the controller and present it
        ac.popoverPresentationController?.barButtonItem =
            self.navigationItem.rightBarButtonItem
        
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
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy)-> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        decisionHandler(.cancel)
    }
}

