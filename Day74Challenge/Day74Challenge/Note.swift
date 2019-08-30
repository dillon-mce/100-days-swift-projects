//
//  Note.swift
//  Day74Challenge
//
//  Created by Dillon McElhinney on 8/27/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class Note: Codable, Equatable {
    var title: String
    var text: String
    var created: Date
    var modified: Date
    let id = UUID()

    var formattedModified: String {
        return Note.dateFormatter.string(from: modified)
    }

    var previewText: String {
        var array = text.components(separatedBy: .newlines)
        array.removeFirst()

        return array.joined(separator: "\n")
    }

    init(title: String,
         text: String,
         created: Date = Date(),
         modified: Date = Date()) {

        self.title = title
        self.text = text
        self.created = created
        self.modified = modified
    }

    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        return dateFormatter
    }()
}
