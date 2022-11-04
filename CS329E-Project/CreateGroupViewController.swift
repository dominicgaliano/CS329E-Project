//
//  CreateGroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

public var users = ["hans", "ray", "dominic", "cruz"]

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var groupIdentifier: UITextField!
    @IBOutlet weak var memberName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var delegate:UIViewController!
    
    // establish db connection
    let db = Firestore.firestore()
    
    //var addedMembers: [String] = []
    var addedMembers = ["hans", "ray"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationBarPlus()

    }
    
    func navigationBarPlus(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Create Group", style: .plain, target: self, action: #selector(createButton))
    }
    
    @objc public func createButton(){
        if groupName.text == ""{
            let controller = UIAlertController(
                title: "Error",
                message: "Please add a group name",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK", style: .default))
            present(controller, animated: true)
        }
//        else if groups.contains(groupName.text!){
//            let controller = UIAlertController(
//                title: "Error",
//                message: "Group name already in use",
//                preferredStyle: .alert)
//            controller.addAction(UIAlertAction(
//                title: "OK", style: .default))
//            present(controller, animated: true)
//        }
        else{
            // create group in database
            addGroup(groupIdentifier: groupIdentifier.text!,
                     groupName: groupName.text!,
                     currentUserUID: Auth.auth().currentUser!.uid)
            
            performSegue(withIdentifier: "CreateGroupSegueBack", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateGroupSegueBack",
            let nextVC = segue.destination as? GroupSelectorViewController{
                nextVC.addGroup(newGroup: groupName.text!)
        }
    }
    
    
    @IBAction func addMemberButton(_ sender: Any) {
        if memberName.text != ""{
            if addedMembers.contains(memberName.text!){
                let controller = UIAlertController(
                    title: "Error",
                    message: "This user is already added",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                    title: "OK", style: .default))
                present(controller, animated: true)
            }
            else if users.contains(memberName.text!){
                addedMembers.append(memberName.text!)
                self.tableView.reloadData()
            }
            else{
                let controller = UIAlertController(
                    title: "Error",
                    message: "This user does not exist",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                    title: "OK", style: .default))
                present(controller, animated: true)
            }
        }
    }
    
    // Adds group to database with unique group id
    func addGroup(groupIdentifier: String, groupName: String, currentUserUID: String) {
        // validate identifier
        if isUnusedGroupIdentifier(groupIdentifier: groupIdentifier) {
            // create group
            db.collection("groups").document("groupIdentifier").setData( [
                "groupName": groupName,
                "users": [currentUserUID]
            ]) {err in
                if let err = err {
                    print("Error adding documet: \(err)")
                } else {
                    print("User document added with id \(groupIdentifier)")
                    // TODO: Add group to user's database entry
                }
            }
        } else {
            // group identifier already used, alert the user
            let controller = UIAlertController(
                title: "Error",
                message: "This groupIdentifier is already in use",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK", style: .default))
            present(controller, animated: true)
        }
    }
    
    // Helper function, checks db for groupIdentifier
    func isUnusedGroupIdentifier(groupIdentifier: String) -> Bool {
        var docRef = db.collection("groups").document(groupIdentifier)
        
        var isUnused: Bool = true
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                isUnused = false
            }
        }
        
        return isUnused
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addedMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath)
        cell.textLabel?.text = addedMembers[row]
        
        return cell
    }
}
