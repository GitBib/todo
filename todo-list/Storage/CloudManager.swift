//
//  CloudManager.swift
//  todo-list
//
//  Created by Ivan on 09.12.2019.
//  Copyright © 2019 Ivan Vyalov. All rights reserved.
//

import UIKit
import CloudKit
import RealmSwift

class CloudManager {
    private static let privateCloudDataBase = CKContainer.default().privateCloudDatabase
    private static var records: [CKRecord] = []
    
    static func fetchDataFromCloud(items: Results<Item>, closure: @escaping (Item) -> ()){
        let query = CKQuery(recordType: "Item", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        privateCloudDataBase.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil else {print(error!); return }
            guard let records = records else { return }
            records.forEach { (record) in
                let newItem = Item(record: record)
                    DispatchQueue.main.async {
                        if newCloudReordIsAvailale(items: items, itemID: newItem.itemID){
                            closure(newItem)
                        }
                    }
                }
        }
        
    }
    
    static func saveDataToCloud(item: Item, clouser: @escaping (String)-> ()){
        let record = CKRecord(recordType: "Item")
        
        record.setValue(item.itemID, forKey: "itemID")
        record.setValue(item.title, forKey: "title")
        let done = Int(truncating: NSNumber(value:item.done))
        record.setValue(done, forKey: "done")
        
        privateCloudDataBase.save(record) { (newRecord, error) in
            if let error = error { print(error); return }
            print("privateCloudDataBase")
            if let newRecord = newRecord {
                clouser(newRecord.recordID.recordName)
            }
        }
    }
    
    static func updateDataCloud(item: Item){
        let recordID = CKRecord.ID(recordName: item.recordID)
        
        privateCloudDataBase.fetch(withRecordID: recordID) { (record, error) in
            if let record = record, error == nil {
                DispatchQueue.main.async {
                    record.setValue(item.title, forKey: "title")
                    record.setValue(item.done, forKey: "done")
                    privateCloudDataBase.save(record) { (_, error) in
                        if let error = error {print(error.localizedDescription); return }
                    }
                    
                }
            }
        }
    }
    
    static func deleteRecord(record: String) {
        let recordID = CKRecord.ID(recordName: record)
        
        privateCloudDataBase.fetch(withRecordID: recordID) { (record, error) in
            if let _ = record, error == nil {
                DispatchQueue.main.async {
                    privateCloudDataBase.delete(withRecordID: recordID) { (_, error) in
                        if let error = error {print(error.localizedDescription); return }
                    }
                    
                }
            }
        }
    }
    
    private static func newCloudReordIsAvailale(items: Results<Item>, itemID: String) -> Bool {
        if items.isEmpty { return true }
        for item in items {
            if item.itemID == itemID {
                return false
            }
        }
        return true
    }
}
