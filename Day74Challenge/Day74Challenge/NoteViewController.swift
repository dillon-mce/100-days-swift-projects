//
//  NoteViewController.swift
//  Day74Challenge
//
//  Created by Dillon McElhinney on 8/27/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {

    let notesController = NotesController.shared
    var note: Note?

    @IBOutlet weak var noteTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboardNotifications()
        setupShareSheet()
        noteTextView.delegate = self

        updateViews()
    }

    @IBAction func saveNote(_ sender: Any) {
        guard let text = noteTextView.text, !text.isEmpty else { return }


        if let note = note {
            notesController.updateNote(note, with: text)
        } else {
            notesController.addNote(text: text)
        }

        navigationController?.popViewController(animated: true)
    }

    @IBAction func deleteNote(_ sender: Any) {
        if let note = note {
            notesController.deleteNote(note)
        }

        navigationController?.popViewController(animated: true)
    }

    @IBAction func newNote(_ sender: Any) {
        let newNoteVC = storyboard!.instantiateViewController(withIdentifier: "NoteViewController")

        navigationController?.pushViewController(newNoteVC, animated: true)
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        updateTitle()
    }

    // MARK: - Private Methods

    private func updateViews() {
        defer { updateTitle() }
        guard let note = note else {
            title = "New Note"
            return
        }

        title = note.title
        noteTextView.text = note.text
    }

    private func updateTitle() {
        let title = String(noteTextView.text.prefix { $0 != "\n" })
        guard !title.isEmpty else { return }
        self.title = title
    }

    private func setupKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
    }

    @objc private func adjustForKeyboard(notification: Notification) {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardValue = notification.userInfo?[key] as? NSValue else {
            return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame,
                                                from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            noteTextView.contentInset = .zero
        } else {
            let bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
            noteTextView.contentInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: bottom,
                                                   right: 0)
        }

        noteTextView.scrollIndicatorInsets = noteTextView.contentInset

        let selectedRange = noteTextView.selectedRange
        noteTextView.scrollRangeToVisible(selectedRange)
    }

    private func setupShareSheet() {
        let button = UIBarButtonItem(barButtonSystemItem: .action,
                                     target: self,
                                     action: #selector(presentShareSheet))
        navigationItem.rightBarButtonItem = button

    }

    @objc private func presentShareSheet() {
        guard let text = noteTextView.text else { return }
        let activityVC = UIActivityViewController(activityItems: [text],
                                                  applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem =
            navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }

}

