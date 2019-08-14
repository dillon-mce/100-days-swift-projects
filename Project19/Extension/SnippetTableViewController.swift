//
//  SnippetTableViewController.swift
//  Extension
//
//  Created by Dillon McElhinney on 8/12/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class SnippetTableViewController: UITableViewController {

    let snippetController = SnippetController.shared

    var dismissHandler: ((String) -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return snippetController.numberOfSections()
    }

    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return snippetController.title(for: section)
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return snippetController.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SnippetCell",
                                                 for: indexPath)
        let snippet = snippetController.snippet(for: indexPath)

        cell.textLabel?.text = snippet.title
        cell.detailTextLabel?.text = snippet.text

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let snippet = snippetController.snippet(for: indexPath)

        if let handler = dismissHandler {
            handler(snippet.text)
        }

        navigationController?.popViewController(animated: true)

    }

    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete")
        { (action, view, completion) in
            self.snippetController.deleteSnippet(at: indexPath)
            self.tableView.deleteRows(at: [indexPath],
                                      with: .automatic)
            completion(true)
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal,
                                            title: "Edit")
        { (action, view, completion) in
            let snippet = self.snippetController.snippet(for: indexPath)
            if let snippetVC = self.storyboard?
                .instantiateViewController(withIdentifier: "SnippetViewController")as? SnippetViewController {
                snippetVC.snippet = snippet
                self.navigationController?.pushViewController(snippetVC,
                                                              animated: true)
            }
        }
        editAction.backgroundColor = UIColor(red: 52/255,
                                             green: 199/255,
                                             blue: 89/255,
                                             alpha: 1)
        let config = UISwipeActionsConfiguration(actions: [editAction])
        return config
    }
}
