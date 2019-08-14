//
//  ActionViewController.swift
//  Extension
//
//  Created by Dillon McElhinney on 8/10/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    var pageTitle = ""
    var pageURL = ""

    @IBOutlet weak var scriptView: UITextView!
    @IBOutlet weak var runButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        runButton.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        runButton.layer.cornerRadius = runButton.frame.height/2
        runButton.setTitleColor(.white, for: .normal)

        navigationItem.leftBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .cancel,
                            target: self,
                            action: #selector(cancel))

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)

        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""

                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                            if let string = self?.pageURL {
                                self?.loadHost(from: string)
                            }
                    }
                }
            }
        }
    }

    @IBAction func done() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": scriptView.text ?? ""]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary,
                                              typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]

        extensionContext?.completeRequest(returningItems: [item])
    }

    @IBAction func cancel() {
        extensionContext?
            .completeRequest(returningItems: extensionContext?.inputItems)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardValue = notification.userInfo?[key] as? NSValue else {
                    return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame,
                                                from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scriptView.contentInset = .zero
        } else {
            let bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
            scriptView.contentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: bottom,
                                                   right: 0)
        }

        scriptView.scrollIndicatorInsets = scriptView.contentInset

        let selectedRange = scriptView.selectedRange
        scriptView.scrollRangeToVisible(selectedRange)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SnippetTableViewController {
            destination.dismissHandler = { [weak self] text in
                self?.scriptView.text = text
            }
        }
    }

    private func loadHost(from urlString: String) {
        if let url = URL(string: urlString) {
            let host = url.host
            SnippetController.currentHost = host
        }
    }

}
