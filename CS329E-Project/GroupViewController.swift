//
//  GroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore

class GroupViewController: UIViewController {
    
    // outlets
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var groupIdentifier:String!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}
