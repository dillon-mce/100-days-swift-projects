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
    var websiteController: WebsiteController!
    var selectedWebsite: String?

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

    @objc func openTapped() {
        // Make the controller
        let ac = UIAlertController(title: "Open page...",
                                   message: nil,
                                   preferredStyle: .actionSheet)
        
        // Make the actions
        for website in websiteController.allowedWebsites {
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
    
    func presentCancelledAlert(for host: String) {
        let message = "Sorry, \(host) is not on the approved list."
        let alertController = UIAlertController(title: "Can't go there!",
                                                message: message,
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func setupViews() {
        // Set up the navigation bar
//        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Open",
                            style: .plain,
                            target: self,
                            action: #selector(openTapped))
        
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
        if let website = selectedWebsite {
            title = website
            let url = URL(string: "https://" + website)!
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
    }
    
    // MARK: - WK Navigation Delegate
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy)-> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            if websiteController.isAllowedToGo(to: host) {
                decisionHandler(.allow)
                return
            } else {
                presentCancelledAlert(for: host)
            }
        }
        decisionHandler(.cancel)
    }
}

