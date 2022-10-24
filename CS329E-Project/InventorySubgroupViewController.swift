//
//  InventorySubgroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit

var Kitchen = ["Apples", "Cheese", "Chicken", "Big Pot"]
var Restroom = ["Hand Soap", "Shampoo", "Body Wash"]
var Bedroom = ["Light Bulbs", "Pens", "Notebook"]

class InventorySubgroupViewController: UITableViewController {
    
    let textCellIdentifier = "TextCell"

    var subgroupSelected:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if subgroupSelected == "Kitchen" {
            return Kitchen.count
        }
        else if subgroupSelected == "Restroom" {
            return Restroom.count
        }
        else if subgroupSelected == "Bedroom" {
            return Bedroom.count
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)

        if subgroupSelected == "Kitchen" {
            cell.textLabel?.text = Kitchen[indexPath.row]        }
        else if subgroupSelected == "Restroom" {
            cell.textLabel?.text = Restroom[indexPath.row]        }
        else if subgroupSelected == "Bedroom" {
            cell.textLabel?.text = Bedroom[indexPath.row]        }
        else {
            return cell
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        /*
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        */
        if subgroupSelected == "Kitchen" {
            Kitchen.remove(at: indexPath.row)
            if editingStyle == .delete {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        else if subgroupSelected == "Restroom" {
            Restroom.remove(at: indexPath.row)
            if editingStyle == .delete {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        else if subgroupSelected == "Bedroom" {
            Bedroom.remove(at: indexPath.row)
            if editingStyle == .delete {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    
    @IBAction func addButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Item", message: "Add a new item to Inventory.", preferredStyle: .alert)
        alertController.addTextField() { (textField) in
            textField.placeholder = "Item"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            if subgroupSelected == "Kitchen" {
                let inputName = alertController.textFields![0].text
                Kitchen.append(inputName!)
                tableView.insertRows(at: [IndexPath(row: Kitchen.count-1, section: 0)], with: .automatic)
            }
            else if subgroupSelected == "Restroom" {
                let inputName = alertController.textFields![0].text
                Restroom.append(inputName!)
                tableView.insertRows(at: [IndexPath(row: Restroom.count-1, section: 0)], with: .automatic)
            
            }
            else if subgroupSelected == "Bedroom" {
                let inputName = alertController.textFields![0].text
                Bedroom.append(inputName!)
                tableView.insertRows(at: [IndexPath(row: Bedroom.count-1, section: 0)], with: .automatic)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
