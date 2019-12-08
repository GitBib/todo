//
//  item.swift
//  todo-list
//
//  Created by Ivan on 08.12.2019.
//  Copyright © 2019 Ivan Vyalov. All rights reserved.
//

struct Item {
    var title: String = ""
    var done: Bool = false
    
    static let totos = ["Find Mike", "Buy Eggos", "Destroy Demogorgon", "Finish the project on swift"]
    
    static func getItems() -> [Item] {
        var items = [Item]()
        for item in totos {
            items.append(Item(title: item, done: false))
        }
        return items
    }
}
