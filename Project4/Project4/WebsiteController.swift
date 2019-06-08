//
//  WebsiteController.swift
//  Project4
//
//  Created by Dillon McElhinney on 6/8/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class WebsiteController {
    var allowedWebsites = [
        "dillon-mce.com",
        "apple.com",
        "hackingwithswift.com",
        "github.com"
    ]
    
    func numberOfRows() -> Int {
        return allowedWebsites.count
    }

    func website(for indexPath: IndexPath) -> String {
        return allowedWebsites[indexPath.row]
    }
    
    func isAllowedToGo(to host: String) -> Bool {
        for website in allowedWebsites {
            if host.contains(website) {
                return true
            }
        }
        return false
    }
}
