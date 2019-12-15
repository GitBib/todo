//
//  NewTodoViewController.swift
//  todo-list
//
//  Created by Ivan on 08.12.2019.
//  Copyright © 2019 Ivan Vyalov. All rights reserved.
//

import UIKit

class NewTodoViewController: UITableViewController {
    var currentItem: Item?
     
    @IBOutlet weak var textTodo: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UISwitch!
    @IBOutlet weak var DoneTableViewCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
         
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        DoneTableViewCell.isHidden = true
        textTodo.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        setupEditItem()
    }
    
    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    
    func saveTodo() {
        let newTodo = Item(title: textTodo.text!,
                           done: doneButton.isOn)
        if currentItem != nil{
            try! realm.write {
                currentItem?.title = newTodo.title
                currentItem?.done = newTodo.done
                CloudManager.updateDataCloud(item: currentItem!)
            }
        } else {
            CloudManager.saveDataToCloud(item: newTodo) { (recordID) in
                DispatchQueue.main.async {
                    try! realm.write {
                        newTodo.recordID = recordID
                    }
                }
            }
            StorageManager.saveObject(newTodo)
        }
    }
    
    @IBAction func CancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func setupEditItem() {
        if currentItem != nil {
            DoneTableViewCell.isHidden = false
            textTodo.text = currentItem?.title
            doneButton.isOn = currentItem?.done ?? false
            setupNavigationBar()
        }
    }

    private func setupNavigationBar(){
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentItem?.title
        saveButton.isEnabled = true
        
    }
}

// MARK: Text field delegate
extension NewTodoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc private func textFieldChange(){
        if textTodo.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}
