//
//  ShoppingListViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ShoppingListItem {
    let itemName: String
    var isChecked: Bool = false
    
    init(itemName: String, isChecked: Bool = false) {
        self.itemName = itemName
        self.isChecked = isChecked
    }
    
    static func == (lhs: ShoppingListItem, rhs: ShoppingListItem) -> Bool {
        return lhs.itemName == rhs.itemName
    }
}

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // define references
    var groupIdentifier:String!
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    
    // define items list
    var shoppingListItems:[ShoppingListItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.shoppingListItems = []
        addIcon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.shoppingListItems == nil {
            print("Table found no shopping list items")
            return 0
        } else {
            print("Table found \(self.shoppingListItems.count) items(s)")
            return self.shoppingListItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        cell.textLabel?.text = shoppingListItems![row].itemName
        cell.accessoryType = shoppingListItems![row].isChecked ? .checkmark : .none
        return cell
    }
    
    func reloadTableData() {
        // get group shopping list data from database
        let groupRef = db.collection("groups").document(groupIdentifier!)
        
        groupRef.collection("shoppingList").getDocuments() { (querySnapshot, err) in
            if let err = err {
                self.displayError(errorMessage: "Error getting documents: \(err)", unwind: true)
            } else {
                // initialize shoppingLit
                self.shoppingListItems = []
                
                // iterate through user's groups
                for document in querySnapshot!.documents {
                    // get itemName from shopping list
                    let itemName = document.documentID
                    
                    // get item status
                    let itemIsChecked = document.data()["isChecked"] as! Bool
                    
                    // add to list
                    self.shoppingListItems.append(ShoppingListItem(itemName: itemName, isChecked: itemIsChecked))
                    print("Added \(itemName) with status \(itemIsChecked) to list")
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Item", message: "Add a new item to Shopping List.", preferredStyle: .alert)
        alertController.addTextField() { (textField) in
            textField.placeholder = "Item"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            let newItem = alertController.textFields![0].text
            
            // check if item already on list
            let docRef = db.collection("groups").document(self.groupIdentifier)
                .collection("shoppingList").document(newItem!)
            docRef.getDocument { (document, error) in
                if document?.exists ?? false {
                    // item already in list
                    self.displayError(errorMessage: "Item already in shopping list.")
                } else {
                    // item not already in list
                    // add item to database
                    docRef.setData([
                        "isChecked": false
                    ])
                    
                    // add to local list
                    self.shoppingListItems.append(ShoppingListItem(itemName: newItem!))
                    
                    // add to table
                    self.tableView.insertRows(at: [IndexPath(row: self.shoppingListItems.count-1, section: 0)], with: .automatic)
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteChecked(_ sender: Any) {
        
        let controller = UIAlertController (
            title: "Remove All Checkmarks",
            message: "Would you like to remove all checkmarks on the shopping list?",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
            title: "No",
            style: .cancel))
        controller.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { action in
                for item in self.shoppingListItems {
                    if item.isChecked {
                        // remove from database
                        self.db.collection("groups").document(self.groupIdentifier!)
                            .collection("shoppingList").document(item.itemName)
                            .delete() { err in
                                if let err = err {
                                    self.displayError(errorMessage: "Error getting documents: \(err)")
                                } else {
                                    print("Document removed from database")
                                }
                                self.tableView.reloadData()
                            }
                    }
                }
            }))
        present(controller, animated: true)
        
        // reload table
        reloadTableData()
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        let controller = UIAlertController (
            title: "Clear Shopping List",
            message: "Would you like to delete all items off the shopping list?",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
            title: "No",
            style: .cancel))
        controller.addAction(UIAlertAction(
            title: "Yes",
            style: .default,
            handler: { action in
                for item in self.shoppingListItems {
                    if true {
                        // remove from database
                        self.db.collection("groups").document(self.groupIdentifier!)
                            .collection("shoppingList").document(item.itemName)
                            .delete() { err in
                                if let err = err {
                                    self.displayError(errorMessage: "Error getting documents: \(err)")
                                } else {
                                    print("Document removed from database")
                                    self.reloadTableData()
                                }
                            }
                    }
                }
            }))
        present(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let item = shoppingListItems[indexPath.row]
            
            // remove from local list
            self.shoppingListItems.remove(at: indexPath.row)
            
            // remove from database
            db.collection("groups").document(groupIdentifier!)
                .collection("shoppingList").document(item.itemName)
                .delete() { err in
                    if let err = err {
                        self.displayError(errorMessage: "Error getting documents: \(err)")
                    } else {
                        print("Document removed from database")
                        
                        // update table
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = shoppingListItems[indexPath.row]
        
        // update database
        db.collection("groups").document(groupIdentifier!).collection("shoppingList").document(item.itemName).updateData([
            "isChecked": !item.isChecked
        ]) { err in
            if let err = err {
                self.displayError(errorMessage: "Error getting documents: \(err)")
            } else {
                print("Document updated sucessfully")
                // update local copy
                item.isChecked = !item.isChecked
                
                // reload row
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func displayError(errorTitle: String = "Error", errorMessage: String, unwind: Bool = false) {
        let errorController = UIAlertController (
            title: errorTitle,
            message: errorMessage,
            preferredStyle: .alert)
        errorController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: { action in
                if unwind {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }))
        present(errorController, animated: true)
    }
    
    func addIcon(){
        let icon = UIImage(named: "icon.png")
        let image = UIImageView(image: icon)
        
        image.contentMode = .scaleAspectFit
        let title = UIView(frame:CGRect(x: 0, y: 0, width: 44, height: 44))
        image.frame = title.bounds
        title.addSubview(image)
        navigationItem.titleView = title
    }
}
