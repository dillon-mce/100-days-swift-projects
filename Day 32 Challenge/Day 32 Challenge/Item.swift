//
//  Item.swift
//  Day 32 Challenge
//
//  Created by Dillon McElhinney on 6/15/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

struct Item {
    var name: String
    var isCompleted = false
    
    init(name: String) {
        self.name = name
    }
    
    static let itemChangedNotification = Notification.Name("ItemChanged")
    static let newIndexPath = "newIndexPath"
    static let oldIndexPath = "oldIndexPath"
    static let indexPaths = "indexPaths"
    static let changeType = "changeType"
}

enum ItemUpdateType {
    case add, remove, update, move
}
