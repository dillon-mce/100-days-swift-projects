//
//  ShoppingListModel.swift
//  Day 32 Challenge
//
//  Created by Dillon McElhinney on 6/15/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import Foundation

class ShoppingListModel {
    
    private var shoppingList: [[Item]] = [[],[]]
    
    func addToList(_ itemName: String) {
        let item = Item(name: itemName)
        shoppingList[0].insert(item, at: 0)
        let userInfo: [AnyHashable: Any] = [
            Item.newIndexPath: IndexPath(row: 0, section: 0),
            Item.changeType: ItemUpdateType.add
        ]
        NotificationCenter.default.post(name: Item.itemChangedNotification,
                                        object: self,
                                        userInfo: userInfo)
    }
    
    func numberOfSections() -> Int {
        return 2
    }
    
    func numberOfRows(in section: Int) -> Int {
        return shoppingList[section].count
    }
    
    func item(for indexPath: IndexPath) -> Item {
        return shoppingList[indexPath.section][indexPath.row]
    }
    
    func generateSharableList() -> String {
        var string = ""
        let incompleteList = shoppingList[0].map { "- [ ] \($0.name)" }
        let completeList = shoppingList[1].map { "- [x] \($0.name)" }
        string += incompleteList.joined(separator: "\n")
        if incompleteList.count > 0 { string += "\n" }
        string += completeList.joined(separator: "\n")
        return string
    }
    
    func toggleCompletedOnItem(at indexPath: IndexPath) -> Bool {
        shoppingList[indexPath.section][indexPath.row].isCompleted.toggle()
        let newSection = indexPath.section == 0 ? 1 : 0
        moveItem(at: indexPath, to: IndexPath(row: 0, section: newSection))
        return true
    }

    func moveItem(at oldIndexPath: IndexPath,
                  to newIndexPath: IndexPath) {
        let item = shoppingList[oldIndexPath.section].remove(at: oldIndexPath.row)
        shoppingList[newIndexPath.section].insert(item, at: newIndexPath.row)
        let userInfo: [AnyHashable: Any] = [
            Item.newIndexPath: newIndexPath,
            Item.oldIndexPath: oldIndexPath,
            Item.changeType: ItemUpdateType.move
        ]
        NotificationCenter.default.post(name: Item.itemChangedNotification,
                                        object: self,
                                        userInfo: userInfo)
        
    }
    
    func clearList() {
        var indexPaths: [IndexPath] = []
        for section in 0..<shoppingList.count {
            for row in 0..<shoppingList[section].count {
                indexPaths.append(IndexPath(row: row,
                                            section: section))
            }
            shoppingList[section].removeAll()
        }
        let userInfo: [AnyHashable: Any] = [
            Item.changeType: ItemUpdateType.remove,
            Item.indexPaths: indexPaths
        ]
        NotificationCenter.default.post(name: Item.itemChangedNotification,
                                        object: self,
                                        userInfo: userInfo)
    }
    
    func loadSampleData() {
        addToList("Item 6")
        addToList("Item 5")
        addToList("Item 4")
        addToList("Item 3")
        addToList("Item 2")
        addToList("Item 1")
    }
}
