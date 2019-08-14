//
//  SnippetViewController.swift
//  Extension
//
//  Created by Dillon McElhinney on 8/12/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class SnippetViewController: UIViewController {

    var snippet: Snippet?
    var snippetController = SnippetController.shared

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()
    }

    @IBAction func saveSnippet(_ sender: Any) {

        guard let title = titleTextField.text,
                !title.isEmpty,
                let text = bodyTextView.text,
                !text.isEmpty else { return }

        if let snippet = snippet {
            snippetController.updateSnippet(snippet,
                                            title: title,
                                            text: text)
        } else {
            snippetController.addSnippet(title: title,
                                         text: text)
        }

        navigationController?.popViewController(animated: true)
    }

    private func updateViews() {
        guard let snippet = snippet else {
            title = "New Snippet"
            return
        }

        title = snippet.title
        titleTextField.text = snippet.title
        bodyTextView.text = snippet.text
    }
}
