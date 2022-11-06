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
    var userData:Dictionary<String, Any>!
    var userGroups:[String]!
    
    // establish db connection
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("User logged in with UID: \(Auth.auth().currentUser!.uid)")
        
        // Access users collection
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing: )) ?? "nil"
                print("User current data: \(dataDescription)")
                
                // set local userData variable to database values
                // self.userData = document.data()
                self.userGroups = document.data()!["groups"] as? [String]
                self.tableView.reloadData()
            } else {
                print("User does not exist, logging out")
                self.performLogout()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userGroups == nil {
            print("Table found no groups, 0")
            return 0
        } else {
            print("Table found \(self.userGroups.count) groups")
            return self.userGroups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        cell.textLabel?.text = groups[row]
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateGroupSegue",
            let nextVC = segue.destination as? CreateGroupViewController{
                nextVC.delegate = self
         
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
