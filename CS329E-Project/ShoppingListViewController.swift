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

class ShoppingListViewController: UITableViewController {

    // define references
    let textCellIdentifier = "TextCell"
    var groupIdentifier:String!
    let db = Firestore.firestore()
    
    // define items list
    var shoppingListItems:[ShoppingListItem]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.shoppingListItems = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.shoppingListItems == nil {
            print("Table found no shopping list items")
            return 0
        } else {
            print("Table found \(self.shoppingListItems.count) items(s)")
            return self.shoppingListItems.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                print("Error getting documents: \(err)")
                // throw error message?
                self.navigationController?.popToRootViewController(animated: true)
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
        
        // Old method
//        groupRef.getDocument { (document, error ) in
//            if let document = document, document.exists {
//                let groupDescription = document.data()
//
//                // check if group has shopping list
//                if groupDescription!["shoppingList"] != nil {
//                    let currShoppingListItems = (groupDescription!["shoppingList"] as? [String])
//                    for i in 0..<currShoppingListItems!.count {
//                        if !self.shoppingListItems.contains(where: { $0.itemName == currShoppingListItems![i] } ) {
//                            print("\(currShoppingListItems![i]) not found in ShoppingListItems, adding")
//                            self.shoppingListItems.append(ShoppingListItem(itemName: currShoppingListItems![i]))
//                        }
//                    }
//                } else {
//                    // no shopping list, need to add
//                    print("Error, group has no shopping list yet")
//                }
//                self.tableView.reloadData()
//            } else {
//                print("Document does not exist")
//                self.dismiss(animated: true)
//            }
//        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Item", message: "Add a new item to Shopping List.", preferredStyle: .alert)
        alertController.addTextField() { (textField) in
            textField.placeholder = "Item"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            let newItem = alertController.textFields![0].text
            
            // add to database
            let groupRef = db.collection("groups").document(self.groupIdentifier)
            
            groupRef.updateData([
                "shoppingList": FieldValue.arrayUnion([newItem!])
            ]) { _ in
                print("Added \(String(describing: newItem!)) to group shopping list")
                // self.reloadTableData()
                
                // self.shoppingListItems.append(newItem!)
                self.shoppingListItems.append(ShoppingListItem(itemName: newItem!))
                self.tableView.insertRows(at: [IndexPath(row: self.shoppingListItems.count-1,
                                                    section: 0)],
                                     with: .automatic)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteChecked(_ sender: Any) {
        // TODO: alert controller to confirm action
        // TODO: Implement
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // remove from local list
            self.shoppingListItems.remove(at: indexPath.row)
            
            // create string version of new list
            var shoppingListItemsString:[String] = []
            for i in 0..<self.shoppingListItems.count {
                shoppingListItemsString.append(self.shoppingListItems[i].itemName)
            }
            
            // remove from database
            let groupRef = db.collection("groups").document(self.groupIdentifier)
            groupRef.updateData([
                "shoppingList": shoppingListItemsString
            ])
            
            // update table
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = shoppingListItems[indexPath.row]
        
        // update database
        db.collection("groups").document(groupIdentifier!).collection("shoppingList").document(item.itemName).updateData([
            "isChecked": !item.isChecked
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document updated sucessfully")
                // update local copy
                item.isChecked = !item.isChecked
                
                // reload row
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
