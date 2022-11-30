//
//  CreateGroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CreateGroupViewController: UIViewController{
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var groupIdentifier: UITextField!
    var delegate:UIViewController!
    
    // establish db connection
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addIcon()
        //Adding unique font
        UILabel.appearance().substituteFontName = "Avenir Next";
        UITextView.appearance().substituteFontName = "Avenir Next";
        UITextField.appearance().substituteFontName = "Avenir Next";
        UIButton.appearance().substituteFontName = "Avenir Next";
        
    }
    
    @IBAction func createGroupButton(_ sender: Any) {
        if groupName.text == ""{
            let controller = UIAlertController(
                title: "Error",
                message: "Please add a group name",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK", style: .default))
            present(controller, animated: true)
        }
        else if groupIdentifier.text == ""{
            let controller = UIAlertController(
                title: "Error",
                message: "Please add a group identifier",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK", style: .default))
            present(controller, animated: true)
        }
        else{
            // create group in database
            addGroup(groupIdentifier: groupIdentifier.text!,
                     groupName: groupName.text!,
                     currentUserUID: Auth.auth().currentUser!.uid)
        }
    }
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "CreateGroupSegueBack",
    //            let nextVC = segue.destination as? GroupSelectorViewController{
    //                nextVC.addGroup(newGroup: groupName.text!)
    //        }
    //    }
    
    // Adds group to database with unique group id
    func addGroup(groupIdentifier: String, groupName: String, currentUserUID: String) {
        // define variables and db reference
        let docRef = db.collection("groups").document(groupIdentifier)
        
        // validate identifier
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // group identifier already used, alert the user
                let controller = UIAlertController(
                    title: "Error",
                    message: "This groupIdentifier is already in use",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                    title: "OK", style: .default))
                self.present(controller, animated: true)
                
            } else {
                // group not used, can create group
                // create group
                self.db.collection("groups").document(groupIdentifier).setData( [
                    "groupName": groupName,
                    "users": [currentUserUID],
                    "inventory": [],
                    "calendarEntries": []
                ]) {err in
                    if let err = err {
                        print("Error adding documet: \(err)")
                    } else {
                        print("User document added with id \(groupIdentifier)")
                        
                        // Add group to user's database entry
                        self.addGroupToUserDocument(currentUserUID: currentUserUID, groupIdentifier: groupIdentifier, groupName: groupName)
                    }
                }
            }
        }
    }
    
    // Helper funciton, add group to user's group list
    // This function should only be called upon sucessful creation of group
    func addGroupToUserDocument(currentUserUID: String, groupIdentifier: String, groupName: String) {
        let userGroupRef = db.collection("users").document(currentUserUID).collection("groups").document(groupIdentifier)
        
        userGroupRef.setData(["groupName" : groupName])
        
        // exit VC
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func addIcon(){
        let icon = UIImage(named: "icon.png")
        let image = UIImageView(image: icon)
        
        image.contentMode = .scaleAspectFit
        let title = UIView(frame:CGRect(x: 0, y: 0, width: 44, height: 44))
        image.frame = title.bounds
        title.addSubview(image)
        navigationItem.titleView = title
    }
}
