//
//  SnippetController.swift
//  Extension
//
//  Created by Dillon McElhinney on 8/12/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class SnippetController {
    static let shared = SnippetController()
    private init() { loadSnippets() }

    private var snippets: [Snippet] = [] {
        didSet {
            sortSnippets()
        }
    }

    private var sortedSnippets: [[Snippet]] = []
    private var sectionNames: [String] = []

    static var currentHost: String? {
        didSet {
            shared.sortSnippets()
        }
    }

    // MARK: - CRUD Methods
    func addSnippet(title: String, text: String) {
        let snippet = Snippet(title: title,
                              text: text,
                              host: SnippetController.currentHost)
        snippets.append(snippet)
        saveSnippets()
    }

    func updateSnippet(_ snippet: Snippet,
                       title: String,
                       text: String) {
        snippet.title = title
        snippet.text = text
        if let host = SnippetController.currentHost {
            snippet.hosts.insert(host)
        }
        saveSnippets()
        sortSnippets()
    }

    func deleteSnippet(at indexPath: IndexPath) {
        let snippet = sortedSnippets[indexPath.section][indexPath.row]
        if let index = snippets.firstIndex(of: snippet) {
            snippets.remove(at: index)
            saveSnippets()
        }
    }

    // MARK: - Tableview API
    func numberOfSections() -> Int {
        return sortedSnippets.count
    }

    func title(for section: Int) -> String {
        return sectionNames[section]
    }

    func numberOfRows(in section: Int) -> Int {
        return sortedSnippets[section].count
    }

    func snippet(for indexPath: IndexPath) -> Snippet {
        return sortedSnippets[indexPath.section][indexPath.row]
    }

    // MARK: - Persistence
    private let saveURL: URL = {
        let url = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)
            .first!
            .appendingPathComponent("snippets")
            .appendingPathExtension("json")
        return url
    }()

    func saveSnippets() {
        do {
            let data = try JSONEncoder().encode(snippets)
            try data.write(to: saveURL)
        } catch {
            print("Error saving snippets\n\(error)")
        }
    }

    func loadSnippets() {
        guard let data = FileManager
            .default
            .contents(atPath: saveURL.path) else { return }
        do {
            let snippets = try JSONDecoder().decode([Snippet].self,
                                                    from: data)
            self.snippets = snippets
        } catch {
            print("Error loading snippets\n\(error)")
        }
    }

    // MARK: - Private Helpers
    private func sortSnippets() {
        if let host = SnippetController.currentHost {
            let prioritySnippets = snippets.filter { $0.hosts.contains(host) }
            let otherSnippets = snippets.filter { !$0.hosts.contains(host) }
            sortedSnippets = [prioritySnippets, otherSnippets]
            sectionNames = ["Priority Snippets", "Everything Else"]
        } else {
            sortedSnippets = [snippets]
            sectionNames = ["All Snippets"]
        }
    }
}
