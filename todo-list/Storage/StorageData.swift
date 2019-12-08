//
//  StorageData.swift
//  todo-list
//
//  Created by Ivan on 08.12.2019.
//  Copyright © 2019 Ivan Vyalov. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func saveObject (_ item: Item) {
        try! realm.write {
            realm.add(item)
        }
    }
    
    static func deleteObject(_ item: Item){
        try! realm.write {
            realm.delete(item)
        }
    }
}
