//
//  ShoppingListViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore

var items = ["Apples", "Toilet Paper", "Chicken Wings", "Oranges", "Tide Pods"]

class ShoppingListViewController: UITableViewController {

    // define references
    let textCellIdentifier = "TextCell"
    var groupIdentifier:String!
    let db = Firestore.firestore()
    
    // define items list
    var shoppingListItems:[String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get group shopping list data from database
        let groupRef = db.collection("groups").document(groupIdentifier!)
        
        groupRef.getDocument { (document, error ) in
            if let document = document, document.exists {
                let groupDescription = document.data()
                
                // check if group has shopping list
                if groupDescription!["shoppingList"] != nil {
                    self.shoppingListItems = groupDescription!["shoppingList"] as? [String]
                } else {
                    // no shopping list, need to add
                    print("Error, group has no shopping list yet")
                }
                self.tableView.reloadData()
            } else {
                print("Document does not exist")
                self.dismiss(animated: true)
            }
        }
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
        cell.textLabel?.text = shoppingListItems![row]
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        /*
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        */
        }    
    }
    
    @IBAction func addButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Item", message: "Add a new item to Shopping List.", preferredStyle: .alert)
        alertController.addTextField() { (textField) in
            textField.placeholder = "Item"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            let inputName = alertController.textFields![0].text
            items.append(inputName!)
            tableView.insertRows(at: [IndexPath(row: items.count-1, section: 0)], with: .automatic)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
