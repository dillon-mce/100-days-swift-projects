//
//  Photo.swift
//  Day50Challenge
//
//  Created by Dillon McElhinney on 7/9/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class Photo: Codable {
    let fileName: String
    var caption: String
    
    init(fileName: String, caption: String = "") {
        self.fileName = fileName
        self.caption = caption
    }
}
