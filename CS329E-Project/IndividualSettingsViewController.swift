//
//  IndividualSettingsViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseAuth

class IndividualSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Change Profile Picture Button
    @IBAction func changePictureButtonPressed(_ sender: Any) {
        // TODO: Implement
        return
    }
    
    // Change Password Button
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
        // TODO: Implement
        return
    }
    
    // Dark mode slider
    @IBAction func darkModeSlider(_ sender: Any) {
        // TODO: Implement
        return
    }
    
    // Logout button
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
                        title: "Confirm Log Out",
                        message: "Are you sure you want to log out?",
                        preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: {
            (action: UIAlertAction!) in (self.performLogout())
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(controller, animated: true)
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
