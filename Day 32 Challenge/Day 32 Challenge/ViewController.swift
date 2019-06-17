//
//  ViewController.swift
//  Day 32 Challenge
//
//  Created by Dillon McElhinney on 6/15/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let shoppingList = ShoppingListModel()
    var addButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setupViews()
    }
    
    // MARK: - UI Actions
    @objc func presentAddItemAlert() {
        let alertController = UIAlertController(title: "Add an item",
                                                message: nil,
                                                preferredStyle: .alert)
        var itemTextField: UITextField!
        alertController.addTextField { textField in
            textField.tintColor = .accentColor
            itemTextField = textField
        }
        
        let addAction = UIAlertAction(title: "Add",
                                      style: .default) { _ in
            guard let item = itemTextField.text else { return }
            self.shoppingList.addToList(item)
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = .accentColor
        present(alertController, animated: true)
    }
    
    // MARK: - UI Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return shoppingList.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = shoppingList.item(for: indexPath)
        if item.isCompleted {
            let attributedString = NSMutableAttributedString(string: item.name)
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: 2,
                .foregroundColor: UIColor.gray
            ]
            let range = NSMakeRange(0, attributedString.length)
            attributedString.addAttributes(attributes,
                                           range: range)
            cell.textLabel?.attributedText = attributedString
        } else {
            cell.textLabel?.text = item.name
        }
        
        return cell
    }

    // MARK: - UI Table View Delegate
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        let completeAction = contextualCompleteAction(for: indexPath)
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [completeAction])
        return swipeConfiguration
    }

    // MARK: - Private Methods
    private func setupViews() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTableView),
                                               name: Item.itemChangedNotification,
                                               object: nil)

        tableView.dataSource = self
        tableView.delegate = self

        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Clear All",
                            style: .plain,
                            target: self,
                            action: #selector(clearList))
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .action,
                            target: self,
                            action: #selector(presentActivityViewController))

        navigationController?.navigationBar.tintColor = .accentColor

        addButton = UIButton()
        addButton.setBackgroundImage(UIImage(named: "plus"),
                                     for: .normal)
        addButton.tintColor = .accentColor
        addButton.addTarget(self,
                            action: #selector(presentAddItemAlert),
                            for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(addButton)

        addButton.heightAnchor.constraint(equalTo: addButton.widthAnchor,
                                          multiplier: 1).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                            constant: -24).isActive = true
        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                          constant: 0).isActive = true

        shoppingList.loadSampleData()
    }
    
    @objc private func updateTableView(_ notification: Notification) {
        guard let updateType = notification.userInfo?[Item.changeType] as? ItemUpdateType else { return }
        let newIndexPath = notification.userInfo?[Item.newIndexPath] as? IndexPath
        let oldIndexPath = notification.userInfo?[Item.oldIndexPath] as? IndexPath
        let indexPaths = notification.userInfo?[Item.indexPaths] as? [IndexPath]
        switch updateType {
        case .add:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let oldIndexPath = oldIndexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: oldIndexPath, to: newIndexPath)
                tableView.reloadRows(at: [newIndexPath], with: .fade)
            }
        case .remove:
            if let indexPaths = indexPaths {
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
        default:
            print("Didn't hit one of the other cases")
            tableView.reloadData()
        }
    }
    
    @objc private func clearList() {
        shoppingList.clearList()
    }
    
    private func contextualCompleteAction(for indexPath: IndexPath) -> UIContextualAction {
        let item = shoppingList.item(for: indexPath)
        let action = UIContextualAction(style: .normal,
                                        title: "Complete")
        { (action, view, completion) in
            completion(self.shoppingList.toggleCompletedOnItem(at: indexPath))
        }
        action.image = UIImage(named: "ok")
        action.backgroundColor = item.isCompleted ? .gray : .orange
        return action
    }
    
    @objc private func presentActivityViewController() {
        let list = shoppingList.generateSharableList()
        let activityViewController =
            UIActivityViewController(activityItems: [list],
                                     applicationActivities: nil)
        present(activityViewController, animated: true)
    }

}

extension UIColor {
    static let accentColor = UIColor(red: 0.2,
                                     green: 0.2,
                                     blue: 0.75,
                                     alpha: 1)
}
