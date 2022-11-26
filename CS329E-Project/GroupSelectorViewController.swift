//
//  GroupSelectorViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class GroupSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    // dark mode
    var darkMode = false
    
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
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        // print("User logged in with UID: \(Auth.auth().currentUser!.uid)")
        
        // Access users groups
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("groups").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.performLogout()
                } else {
                    // initialize userGroups array
                    self.userGroups = []
                    
                    // iterate through user's groups
                    for document in querySnapshot!.documents {
                        // get groupId from user
                        let groupID = document.documentID
                        
                        // get groupName from groups (since they can change)
                        self.db.collection("groups").document(groupID).getDocument { (document, error ) in
                            if let document = document, document.exists {
                                let groupName:String = document.data()!["groupName"] as! String
                                self.userGroups.append((groupID, groupName))
                                self.tableView.reloadData()
                            } else {
                                print("Group does not exist")
                            }
                        }
                    }
                }
            }
        
        // dark mode
        var defaults = UserDefaults.standard
        if defaults.object(forKey: "state") != nil{
            darkMode = defaults.bool(forKey: "state")
        }
        
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            if darkMode == true {
                appDelegate?.overrideUserInterfaceStyle = .dark
                return
            } else {
                appDelegate?.overrideUserInterfaceStyle = .light
            }
            appDelegate?.overrideUserInterfaceStyle = .light
            return
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
        cell.textLabel?.numberOfLines = 0
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
