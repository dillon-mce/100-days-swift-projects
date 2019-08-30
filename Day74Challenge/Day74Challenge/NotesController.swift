//
//  NotesController.swift
//  Day74Challenge
//
//  Created by Dillon McElhinney on 8/27/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class NotesController {
    static let shared = NotesController()
    private init() { loadNotes() }

    var notes: [Note] = []
    private let center = NotificationCenter.default

    // MARK: - CRUD Methods
    func addNote(text: String) {
        let title = getTitle(for: text)
        let note = Note(title: title, text: text)

        notes.append(note)
        saveNotes()

        center.post(name: .notesChanged, object: self)
    }

    func updateNote(_ note: Note,
                    with text: String,
                    at date: Date = Date()) {
        let title = getTitle(for: text)

        note.title = title
        note.text = text
        note.modified = date

        saveNotes()

        center.post(name: .notesChanged, object: self)
    }

    func deleteNote(at indexPath: IndexPath) {
        notes.remove(at: indexPath.row)

        saveNotes()

        center.post(name: .notesChanged, object: self)
    }

    func deleteNote(_ note: Note) {
        guard let index = notes.firstIndex(of: note) else { return }

        notes.remove(at: index)

        saveNotes()

        center.post(name: .notesChanged, object: self)
    }

    private func getTitle(for text: String) -> String {
        var title = String(text.prefix { $0 != "\n" })
        title = title.isEmpty ? "New Note" : title
        return title
    }

    // MARK: - TableView API
    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
        return notes.count
    }

    func note(for indexPath: IndexPath) -> Note {
        return notes[indexPath.row]
    }

    // MARK: - Persistence
    private let saveURL: URL = {
        let url = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)
            .first!
            .appendingPathComponent("notes")
            .appendingPathExtension("json")
        return url
    }()

    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: saveURL)
        } catch {
            print("Error saving notes\n\(error)")
        }
    }

    func loadNotes() {
        guard let data = FileManager
            .default
            .contents(atPath: saveURL.path) else { return }
        do {
            let notes = try JSONDecoder().decode([Note].self,
                                                    from: data)
            self.notes = notes
        } catch {
            print("Error loading notes\n\(error)")
        }
    }
}

extension Notification.Name {
    static let notesChanged = Notification.Name("NotesChanged")
}
