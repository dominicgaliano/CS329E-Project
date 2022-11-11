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

    // define current group id (passed via segue) and db
    var groupIdentifier:String!
    let db = Firestore.firestore()
    
    // define users list
    var groupUsers:[String]!
    
    @IBOutlet weak var qrCode: UIImageView!
    var qrcodeImage:CIImage! = nil
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupCodeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let textCellIdentifier = "MemberCell"
    
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
        
        // make QR code
        makeQrCode(groupName: groupIdentifier)
        
        // get group data from database
        let groupRef = db.collection("groups").document(groupIdentifier!)
        
        groupRef.getDocument { [self] (document, error ) in
            if let document = document, document.exists {
                let groupDescription = document.data()
                
                // set group name and id visuallly
                self.groupNameTextField.text = (groupDescription!["groupName"] as! String)
                self.groupCodeLabel.text = self.groupIdentifier
                
                // check if group has users list (it should)
                if groupDescription!["users"] != nil {
                    let groupMemberIDs = groupDescription!["users"] as? [String]
                    
                    // Convert user IDs to first and last names
                    self.groupUsers = []
                    for i in 0..<groupMemberIDs!.count {
                        // query db for user
                        let userRef = db.collection("users").document(groupMemberIDs![i] as String)
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
                            }
                        }
                    }
                    // display users
                    self.tableView.reloadData()
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
        }
    }
}
