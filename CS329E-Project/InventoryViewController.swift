//
//  InventoryViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore

var subgroups = ["Kitchen", "Restroom", "Bedroom"]

class InventoryViewController: UITableViewController {
    
    let inventorySubgroupSegueIdentifier = "inventorySubgroupSegueIdentifier"
    let textCellIdentifier = "TextCell"
    var groupIdentifier:String!
    let db = Firestore.firestore()
    
    // define items list
    var inventoryItems:[String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Data manipulation
    
    func reloadTableData() {
        // get group shopping list data from database
        let groupRef = db.collection("groups").document(groupIdentifier!)
        
        groupRef.getDocument { (document, error ) in
            if let document = document, document.exists {
                let groupDescription = document.data()
                
                // check if group has shopping list
                if groupDescription!["inventory"] != nil {
                    self.inventoryItems = groupDescription!["inventory"] as? [String]
                } else {
                    // no shopping list, need to add
                    print("Error, group has no inventory list yet")
                }
                self.tableView.reloadData()
            } else {
                print("Document does not exist")
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Item", message: "Add a new item to inventory.", preferredStyle: .alert)
        alertController.addTextField() { (textField) in
            textField.placeholder = "Item"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            let newItem = alertController.textFields![0].text
            
            // add to database
            let groupRef = db.collection("groups").document(self.groupIdentifier)
            
            groupRef.updateData([
                "inventory": FieldValue.arrayUnion([newItem!])
            ]) { _ in
                print("Added \(String(describing: newItem!)) to group inventory")
                // self.reloadTableData()
                
                self.inventoryItems.append(newItem!)
                self.tableView.insertRows(at: [IndexPath(row: self.inventoryItems.count-1,
                                                    section: 0)],
                                     with: .automatic)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.inventoryItems == nil {
            print("Table found no shopping list items")
            return 0
        } else {
            print("Table found \(self.inventoryItems.count) items(s)")
            return self.inventoryItems.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        cell.textLabel?.text = inventoryItems![row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Cruz, implement adding stuff to shoppingList here
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // remove from local list
            self.inventoryItems.remove(at: indexPath.row)
            
            // TODO: remove from database
            let groupRef = db.collection("groups").document(self.groupIdentifier)
            groupRef.updateData([
                "inventory": inventoryItems!
            ])
            
            // update table
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // TODO: Remove
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == inventorySubgroupSegueIdentifier,
           let destination = segue.destination as? InventorySubgroupViewController,
           let subgroupsIndex = tableView.indexPathForSelectedRow?.row {
            destination.subgroupSelected = subgroups[subgroupsIndex]
        }
    }
}
