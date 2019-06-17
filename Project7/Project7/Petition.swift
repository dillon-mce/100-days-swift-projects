//
//  Petition.swift
//  Project7
//
//  Created by Dillon McElhinney on 6/17/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}

struct Petitions: Codable {
    var results: [Petition]
}
