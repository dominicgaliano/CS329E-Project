//
//  JoinGroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


protocol fillGroupCode{
    func updateTextField(code:String)
}

class JoinGroupViewController: UIViewController, fillGroupCode {
    
    // Personal notes:
    // First need to get a group id from user from text entry or QR code
    // Need to validate group id
    // if valid, need to add user to group and add group to user's groups
    
    // define db reference
    let db = Firestore.firestore()
    var userGroups:[String]!
    
    @IBOutlet weak var joinGroupID: UITextField!
    
    var delegate: UIViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addIcon()
        //Adding unique font
        UILabel.appearance().substituteFontName = "Avenir Next";
        UITextView.appearance().substituteFontName = "Avenir Next";
        UITextField.appearance().substituteFontName = "Avenir Next";
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScannerSegue",
           let nextVC = segue.destination as? ScannerViewController{
            nextVC.delegate = self
        }
    }
    
    @IBAction func joinGroupButton(_ sender: Any) {
        // only called if user is not using QR code
        
        // check if groupName is empty
        if joinGroupID.text == ""{
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
            joinGroup(groupIdentifier: joinGroupID.text!,
                      currentUserUID: Auth.auth().currentUser!.uid)
        }
    }
    
    
    func updateTextField(code: String) {
        joinGroupID.text = code
    }
    
    func joinGroup(groupIdentifier: String, currentUserUID: String) {
        // define variables and db reference
        let groupRef = db.collection("groups").document(groupIdentifier)
        
        // validate identifier
        groupRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // valid group id
                
                // get group name
                let groupName:String = document["groupName"]! as! String
                
                // check if user already in group
                self.db.collection("users").document(Auth.auth().currentUser!.uid)
                    .collection("groups").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            self.userGroups = []
                            for document in querySnapshot!.documents {
                                self.userGroups.append(document.documentID)
                            }
                            
                            // if user not already in group
                            if !self.userGroups.contains(groupIdentifier) {
                                // add user to group users list
                                groupRef.updateData([
                                    "users": FieldValue.arrayUnion([currentUserUID])
                                ])
                                
                                // add group to users group list
                                self.addGroupToUserDocument(currentUserUID: currentUserUID, groupIdentifier: groupIdentifier, groupName: groupName)
                            } else {
                                // alert user that they are already in the group
                                let controller = UIAlertController(
                                    title: "Error",
                                    message: "You have already joined the group: \(groupName)",
                                    preferredStyle: .alert)
                                controller.addAction(UIAlertAction(
                                    title: "OK", style: .default))
                                self.present(controller, animated: true)
                            }
                        }
                    }
            } else {
                // invalid group id, alert the user
                let controller = UIAlertController(
                    title: "Error",
                    message: "This group does not exist",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                    title: "OK", style: .default))
                self.present(controller, animated: true)
            }
        }
    }
    
    // Helper funciton, add group to user's group list
    func addGroupToUserDocument(currentUserUID: String, groupIdentifier: String, groupName: String) {
        let userGroupRef = db.collection("users").document(currentUserUID).collection("groups").document(groupIdentifier)
        
        userGroupRef.setData(["groupName" : groupName]) {_ in
            // exit VC
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
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
