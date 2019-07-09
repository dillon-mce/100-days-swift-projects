//
//  Person.swift
//  Project10
//
//  Created by Dillon McElhinney on 6/28/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
