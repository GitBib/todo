//
//  item.swift
//  todo-list
//
//  Created by Ivan on 08.12.2019.
//  Copyright © 2019 Ivan Vyalov. All rights reserved.
//
import RealmSwift
import CloudKit

class Item: Object {
    @objc dynamic var recordID: String = ""
    @objc dynamic var itemID: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    
    convenience init(title: String, done: Bool = false){
        self.init()
        self.title = title
        self.done = done
    }
    
    convenience init(record: CKRecord){
        self.init()
        self.recordID = record.recordID.recordName
        self.itemID = record.value(forKey: "itemID") as! String
        self.title = record.value(forKey: "title") as! String
        self.done = record.value(forKey: "done") as! Bool
    }
    
    static override func primaryKey() -> String? {
        return "itemID"
    }
}
