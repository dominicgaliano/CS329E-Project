//
//  GroupSettingsViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class GroupSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // define button
    @IBOutlet weak var editButton: UIButton!
    
    // define current group id (passed via segue) and db
    var groupIdentifier:String!
    let db = Firestore.firestore()
    
    // define users list
    var groupUsersIDs:[String]!
    var groupUsers:[String]!
    
    @IBOutlet weak var qrCode: UIImageView!
    var qrcodeImage:CIImage! = nil
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupCodeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let textCellIdentifier = "MemberCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Adding unique font
        UILabel.appearance().substituteFontName = "American Typewriter";
        UITextView.appearance().substituteFontName = "American Typewriter";
        UITextField.appearance().substituteFontName = "American Typewriter";
        UIButton.appearance().substituteFontName = "American Typewriter";

        tableView.delegate = self
        tableView.dataSource = self
        
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        addIcon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // guard against no group selected
        if groupIdentifier == nil {
            print("Must select a group, cannot use shortcut anymore")
            dismiss(animated: true)
        }
        
        // make QR code
        makeQrCode(groupName: groupIdentifier)
        
        // get group data from database
        let groupRef = db.collection("groups").document(groupIdentifier!)
        
        groupRef.getDocument { [self] (document, error ) in
            if let document = document, document.exists {
                let groupDescription = document.data()
                
                // set group name and id visuallly
                self.groupNameLabel.text = (groupDescription!["groupName"] as! String)
                self.groupCodeLabel.text = "Group ID: \(self.groupIdentifier ?? "")"
                
                // check if group has users list (it should)
                if groupDescription!["users"] != nil {
                    self.groupUsersIDs = groupDescription!["users"] as? [String]
                    
                    // Convert user IDs to first and last names
                    self.groupUsers = []
                    for i in 0..<self.groupUsersIDs!.count {
                        // query db for user
                        let userRef = db.collection("users").document(self.groupUsersIDs![i] as String)
                        userRef.getDocument { (document, error ) in
                            if let document = document, document.exists {
                                let userData = document.data()
                                
                                // check if user has first and last name (it should)
                                if let firstName = userData!["firstName"], let lastName = userData!["lastName"] {
                                    // add users to list
                                    self.groupUsers.append("\(firstName) \(lastName)")
                                } else {
                                    print("user has not first and last name")
                                    self.dismiss(animated: true, completion: nil)
                                }
                                // display users
                                self.tableView.reloadData()
                            }
                        }
                    }
                } else {
                    // no users, this is a bad error
                    print("Error, group has no users yet")
                    self.dismiss(animated: true)
                }
            } else {
                print("Document does not exist")
                self.dismiss(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.groupUsers == nil {
            print("Table found no users")
            return 0
        } else {
            print("Table found \(self.groupUsers.count) items(s)")
            return self.groupUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        cell.textLabel?.text = groupUsers![row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func makeQrCode(groupName:String){
        qrcodeImage = nil
        if groupName.isEmpty {return}
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {return}
        guard let data = groupName.data(using: .isoLatin1, allowLossyConversion: false) else {return}
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        qrcodeImage = filter.outputImage
        if let qrcodeImage = qrcodeImage{
            qrCode.image = UIImage(ciImage: qrcodeImage)
            qrCode.layer.magnificationFilter = CALayerContentsFilter.nearest
        }
    }
    
    // leave group button
    @IBAction func leaveGroupButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Confirm Action",
            message: "Are you sure you want to leave the group? If you are the last member this group will be deleted.",
            preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {
            (action: UIAlertAction!) in (self.leaveGroup(Auth.auth().currentUser!.uid, self.groupIdentifier!))
            self.performSegue(withIdentifier: "LeaveGroupSegue", sender: nil)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(controller, animated: true)
    }
    
    // leave group
    func leaveGroup(_ uid: String, _ groupID: String) {
        // remove user from group doc
        removeUserFromGroup(uid, groupID)
        
        // remove group from user doc
        removeGroupFromUserDoc(uid, groupID)
    }
    
    func removeUserFromGroup(_ uid: String, _ groupID: String) {
        let groupRef = db.collection("groups").document(groupID)
        
        let newUsersList:[String] = groupUsersIDs!.filter { $0 != uid }
        print(newUsersList)
        
        if newUsersList != [] {
            groupRef.updateData([
                "users": newUsersList
            ])
        } else {
            // user was the last one in the group
            deleteGroup(groupID)
        }
        
        // return to groupSelector page
        // TODO: go back two VCs somehow, I think unwind segue might work?
        
    }
    
    func removeGroupFromUserDoc(_ uid: String, _ groupID: String) {
        db.collection("users").document(uid).collection("groups").document(groupID).delete() { err in
            if let err = err {
                print("Error removing document \(err)")
            } else {
                print("Group documented deleted")
            }
        }
    }
    
    func deleteGroup(_ groupID: String) {
        db.collection("groups").document(groupID).delete() { err in
            if let err = err {
                print("Error removing document \(err)")
            } else {
                print("Group documented deleted")
            }
        }
    }
    
    // change group name
    @IBAction func changeGroupNameButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Change Group Name", message: "What would you like your group to be called?", preferredStyle: .alert)
        alertController.addTextField() { (textField) in
            textField.placeholder = "New Group Name"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [self] _ in
            let newGroupName:String = alertController.textFields![0].text!
            
            // add to database
            let groupRef = db.collection("groups").document(self.groupIdentifier)
            
            groupRef.updateData([
                "groupName": newGroupName
            ]) { _ in
                print("Group name changed to \(newGroupName)")
                self.groupNameLabel.text = newGroupName
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
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
