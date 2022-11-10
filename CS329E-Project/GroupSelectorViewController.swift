//
//  GroupSelectorViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol groupAdder{
    func addGroup(newGroup:String)
}

public var groups = ["group1", "group2", "group3"]
class GroupSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, groupAdder{

    @IBOutlet weak var tableView: UITableView!
    var delegate:UIViewController!
    var userGroups:[(String, String)]!
    
    // establish db connection
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // print("User logged in with UID: \(Auth.auth().currentUser!.uid)")
        
        // Access users groups
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("groups").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.performLogout()
                } else {
                    self.userGroups = []
                    for document in querySnapshot!.documents {
                        self.userGroups.append((document.documentID,
                                           document.data()["groupName"] as! String))
                    }
                    self.tableView.reloadData()
                    // for debugging
                    print(self.userGroups!)
                }
            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userGroups == nil {
            print("Table found no groups, 0")
            return 0
        } else {
            print("Table found \(self.userGroups.count) group(s)")
            return self.userGroups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        cell.textLabel?.text = userGroups[row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "groupIdentifier",
                             sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateGroupSegue",
            let nextVC = segue.destination as? CreateGroupViewController{
                nextVC.delegate = self
        } else if segue.identifier == "groupIdentifier",
                  let nextVC = segue.destination as? GroupViewController {
            nextVC.groupIdentifier = userGroups[(sender as! Int)].0
        } else if segue.identifier == "JoinGroupSegue",
                  let nextVC = segue.destination as? JoinGroupViewController {
            // TODO: can put something here if needed, but might be able to delete this
        }
    }
    
    func addGroup(newGroup: String) {
        groups.append(newGroup)
        //self.tableView.reloadData()
    }
    
    // Perform logout
    func performLogout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
