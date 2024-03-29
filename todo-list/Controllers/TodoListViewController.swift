//
//  ViewController.swift
//  todo-list
//
//  Created by Ivan on 08.12.2019.
//  Copyright © 2019 Ivan Vyalov. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    
    var itemArray: Results<Item>!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemArray = realm.objects(Item.self)
        
        CloudManager.fetchDataFromCloud(items: itemArray) { (item) in
            StorageManager.saveObject(item)
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.isEmpty ? 0 : itemArray.count
    }
    
    //MARK: - Swipe actions
    override func tableView(_ tableView: UITableView,
    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    ->   UISwipeActionsConfiguration? {
        
        let item = itemArray[indexPath.row]
        
        let titleDone = item.done ?
          NSLocalizedString("Undone", comment: "Undone") :
          NSLocalizedString("Done", comment: "Done")
        
        let titleDelete = NSLocalizedString("Delete", comment: "Delete")
        
        let actionDelete = UIContextualAction(style: .destructive, title: titleDelete,
          handler: { (action, view, completionHandler) in
            self.showAlert(title: "To delete a item?", message: "This item will be delete from all your devices") {
                CloudManager.deleteRecord(record: item.recordID)
                StorageManager.deleteObject(item)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completionHandler(true)
        })
        
        let actionDone = UIContextualAction(style: .normal, title: titleDone,
          handler: { (action, view, completionHandler) in
            try! realm.write {
                self.itemArray[indexPath.row].done = !self.itemArray[indexPath.row].done
            }
            CloudManager.updateDataCloud(item: item)
            tableView.reloadData()
            completionHandler(true)
        })
        
        let configuration = UISwipeActionsConfiguration(actions: [actionDone, actionDelete])
        return configuration
    }
    
    
    //MARK: - Tableview items
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]

        cell.textLabel?.text = item.title
        cell.accessoryType = item.done == true ? .checkmark : .none

        return cell
    }
    
    //MARK: - Add Button
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        guard let newTodoVC = segue.source as? NewTodoViewController else  { return }
        newTodoVC.saveTodo()
        tableView.reloadData()
    }
    
    //MARK: - Show detail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let item = itemArray[indexPath.row]
            let newTodoVC = segue.destination as! NewTodoViewController
            newTodoVC.currentItem = item
        }
    }
    
    private func showAlert(title: String, message: String, closure: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            closure()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
