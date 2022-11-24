//
//  GroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Foundation

class GroupMessage {
    let displayName: String
    let messageContent: String
    let messageTimestamp: Date
    let dateFormatter = DateFormatter()
    
    init(displayName: String, messageContent: String, messageTimestamp: Date) {
        self.displayName = displayName
        self.messageContent = messageContent
        self.messageTimestamp = messageTimestamp
        dateFormatter.dateFormat = "MMM d, hh:mm"
    }
    
    func displayAsString() -> String {
        return "\(self.displayName) said: \(self.messageContent) at \(self.dateFormatter.string(from: self.messageTimestamp))"
    }
}

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
    var groupMessages:[GroupMessage] = []
    
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
        
        // reload messages
        self.reloadMessages(groupIdentifier: groupIdentifier!)
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
    
    func reloadMessages(groupIdentifier: String) {
        let messagesRef = db.collection("groups").document(groupIdentifier).collection("messages")
        messagesRef.order(by: "time", descending: true).limit(to: 100)
        messagesRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                // throw error message?
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                // initialize message lsit
                self.groupMessages = []
                
                // iterate through user's groups
                for document in querySnapshot!.documents {
                    // parse content
                    let displayName:String = document.data()["displayName"] as! String
                    let messageContent:String = document.data()["messageContent"] as! String
                    let messageTimestamp:Date = (document.data()["time"] as! Timestamp).dateValue()
                    
                    // add to list
                    self.groupMessages.append(GroupMessage(displayName: displayName,
                                                           messageContent: messageContent,
                                                           messageTimestamp: messageTimestamp))
                }
                
                self.tableView.reloadData()
            }
        }
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
        let now = Date()
        
        // get users display name
        self.db.collection("users").document(uid)
            .getDocument { (document, error ) in
                if let document = document, document.exists {
                    let userData = document.data()
                    
                    // check if user has first and last name (it should)
                    if let firstName = userData!["firstName"], let lastName = userData!["lastName"] {
                        // add users to list
                        let displayName = "\(firstName) \(lastName)"
                        
                        // Add to database
                        self.db.collection("groups").document(groupIdentifier)
                            .collection("messages").addDocument(data: [
                                "displayName": displayName,
                                "uid": uid,
                                "time": now,
                                "messageContent": messageContent
                            ]) { err in
                                if let err = err {
                                    print("Error: \(err)")
                                } else {
                                    // add to local copy of messages
                                    let newMessage = GroupMessage(displayName: displayName, messageContent: messageContent, messageTimestamp: now)
                                    self.groupMessages.insert(newMessage, at: 0)
                                    
                                    // reload tableView
                                    // TODO: make this an add
                                    self.tableView.reloadData()
                                }
                            }
                    }
                }
            }
    }
                
    // MARK: - Table functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currMessage:GroupMessage = groupMessages[row]
        cell.textLabel?.text = currMessage.displayAsString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
