//
//  Snippet.swift
//  Extension
//
//  Created by Dillon McElhinney on 8/12/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class Snippet: Codable, Equatable {
    var title: String
    var text: String
    var hosts: Set<String> = []

    init(title: String, text: String, host: String?) {
        self.title = title
        self.text = text
        if let host = host {
            self.hosts.insert(host)
        }
    }

    static func == (lhs: Snippet, rhs: Snippet) -> Bool {
        return lhs.text == rhs.text && lhs.title == rhs.title
    }
}
