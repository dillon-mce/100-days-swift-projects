//
//  WebViewController.swift
//  Project16
//
//  Created by Dillon McElhinney on 7/27/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var selectedItem: String?
    
    override func loadView() {
        // Change the default view to be a WKWebView
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isToolbarHidden = true
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func setupViews() {
        
        // Set up the progress view
        progressView = UIProgressView(progressViewStyle: .default)
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        progressView.leadingAnchor
            .constraint(equalTo: view.leadingAnchor)
            .isActive = true
        progressView.trailingAnchor
            .constraint(equalTo: view.trailingAnchor)
            .isActive = true
        progressView.bottomAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            .isActive = true
        
        let keyPath =
            #keyPath(WKWebView.estimatedProgress)
        webView.addObserver(self,
                            forKeyPath: keyPath,
                            options: .new,
                            context: nil)
        
        // Set up the toolbar
        let backward =
            UIBarButtonItem(title: "←",
                            style: .plain,
                            target: webView,
                            action: #selector(webView.goBack))
        
        let spacer1 =
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                            target: nil,
                            action: nil)
        
        let refresh =
            UIBarButtonItem(barButtonSystemItem: .refresh,
                            target: webView,
                            action: #selector(webView.reload))
        let spacer2 =
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                            target: nil,
                            action: nil)
        
        let forward =
            UIBarButtonItem(title: "→",
                            style: .plain,
                            target: webView,
                            action: #selector(webView.goForward))
        
        toolbarItems = [backward, spacer1, refresh, spacer2, forward]
        navigationController?.isToolbarHidden = false
        
        
        // Load a default website
        if let item = selectedItem {
            title = item
            let url = URL(string: "https://wikipedia.org/wiki")?
                .appendingPathComponent(item)
            
            webView.load(URLRequest(url: url!))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
    
    // MARK: - WK Navigation Delegate
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}

