//
//  ViewController.swift
//  Project5
//
//  Created by Dillon McElhinney on 6/9/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    let gameController = GameController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self,
                            action: #selector(promptForAnswer))
        
        startGame()
    }

    
    func startGame() {
        gameController.startGame()
        title = gameController.startWord
        tableView.reloadData()
    }
    
    func submit(_ answer: String) {
        if let alert = gameController.checkAnswer(answer) {
            present(alert, animated: true)
        } else {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
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
                alertController?.textFields?.first?.text else { return }
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
        return gameController.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "WordCell",
                                          for: indexPath)
        
        cell.textLabel?.text = gameController.word(for: indexPath)
        
        return cell
    }
}

