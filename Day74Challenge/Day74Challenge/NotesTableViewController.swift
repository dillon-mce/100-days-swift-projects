//
//  NotesTableViewController.swift
//  Day74Challenge
//
//  Created by Dillon McElhinney on 8/27/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class NotesTableViewController: UITableViewController {

    let notesController = NotesController.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotifications()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return notesController.numberOfSections()
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return notesController.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell",
                                                 for: indexPath)
        let note = notesController.note(for: indexPath)

        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = "\(note.formattedModified)\t\(note.previewText)"

        return cell
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        notesController.deleteNote(at: indexPath)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        switch segue.identifier {
        case "AddNoteSegue":
            break 
        case "ShowNoteSegue":
            guard let destinationVC = segue.destination as? NoteViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let note = notesController.note(for: indexPath)
            destinationVC.note = note
        default:
            print("Found an unsupported segue identifier: \(segue.identifier ?? "")")
            assert(false, "Shouldn't have any identifiers that aren't supported")
        }
    }

    @objc private func updateTableView() {
        self.tableView.reloadData()
    }

    private func setupNotifications() {
        let center = NotificationCenter.default

        center.addObserver(self,
                           selector: #selector(updateTableView),
                           name: .notesChanged,
                           object: nil)
    }

}
