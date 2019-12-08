//
//  item.swift
//  todo-list
//
//  Created by Ivan on 08.12.2019.
//  Copyright © 2019 Ivan Vyalov. All rights reserved.
//
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    convenience init(title: String, done: Bool = false){
        self.init()
        self.title = title
        self.done = done
    }
}
