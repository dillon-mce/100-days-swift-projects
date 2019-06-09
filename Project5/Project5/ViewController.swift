//
//  ViewController.swift
//  Project5
//
//  Created by Dillon McElhinney on 6/9/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var allWords: [String] = []
    var usedWords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(promptForAnswer))
        
        // Pull the list of words out of the file
        if let startWordsURL = Bundle.main.url(forResource: "start",
                                               withExtension: "txt"),
            let startWords = try? String(contentsOf: startWordsURL) {
            allWords = startWords.components(separatedBy: "\n")
        }

        // Provide a default in case something goes wrong.
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }

    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func submit(_ answer: String) {
        print("Submitted '\(answer)'")
    }
    
    @objc func promptForAnswer() {
        // Build an alert controller
        let alertController =
            UIAlertController(title: "Enter answer",
                              message: nil,
                              preferredStyle: .alert)
        // Add a text field to it
        alertController.addTextField()
        
        // Make the submit action
        let submitAction = UIAlertAction(title: "Submit",
                                         style: .default)
        { [weak self, weak alertController] _ in
            // weak references to self and alertController
            // to avoid retain cycles
            guard let answer =
                alertController?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        // Add the action and present it
        alertController.addAction(submitAction)
        present(alertController, animated: true)
    }

    // MARK: UI Table View Data Source
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int)
        -> Int {
        return usedWords.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "WordCell",
                                          for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
    
}

