//
//  GroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // segue identifiers
    let shoppingListSegueIdentifier: String = "shoppingListSegueIdentifier"
    let groupSettingsSegueIdentifier: String = "groupSettingsSegueIdentifier"
    let inventorySegueIdentifier: String = "inventorySegueIdentifier"
    
    // outlets
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var groupIdentifier:String!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // guard against no group selected
        if groupIdentifier == nil {
            print("Must select a group, cannot use shortcut anymore")
            dismiss(animated: true)
        }
        
        // get group data from database
        let groupRef = db.collection("groups").document(groupIdentifier!)
        
        groupRef.getDocument { (document, error ) in
            if let document = document, document.exists {
                // change data where needed
                let groupDescription = document.data()
                print(groupDescription!["groupName"]!)
                
                self.groupNameLabel.text = (groupDescription!["groupName"] as! String)
            } else {
                print("Document does not exist")
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func addMessageButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Message", message: "Add a new message to group message board.", preferredStyle: .alert)
        alertController.addTextField() { (textField) in
            textField.placeholder = "Message"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            let messageContent = alertController.textFields![0].text
            
            // post message
            self.postMessage(messageContent: messageContent!,
                             groupIdentifier: self.groupIdentifier,
                             uid: Auth.auth().currentUser!.uid)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == shoppingListSegueIdentifier,
           let nextVC = segue.destination as? ShoppingListViewController {
            nextVC.groupIdentifier = groupIdentifier
        } else if segue.identifier == groupSettingsSegueIdentifier,
                  let nextVC = segue.destination as? GroupSettingsViewController {
            nextVC.groupIdentifier = groupIdentifier
        } else if segue.identifier == inventorySegueIdentifier,
                  let nextVC = segue.destination as? InventoryViewController {
            nextVC.groupIdentifier = groupIdentifier
        }
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
    }
    
    // Adds message to database and local copy of messages
    func postMessage(messageContent: String, groupIdentifier: String, uid: String) {
        // Add to database
        db.collection("groups").document(groupIdentifier)
            .collection("messages").addDocument(data: [
                "uid": uid,
                "time": Timestamp(date: Date()),
                "messageContent": messageContent
            ]) { err in
                if let err = err {
                    print("Error adding message: \(err)")
                } else {
                    print("Added message")
                    
                    // TODO: Add to local copy of messages
                    
                }
            }
    }
    
    // MARK: - Table functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Test"
        return cell
    }
    
}
