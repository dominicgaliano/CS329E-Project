//
//  IndividualSettingsViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseAuth

class IndividualSettingsViewController: UIViewController {

    // Profile picture outlet
    @IBOutlet weak var profilePicture: UIImageView!
    
    // switch status outlet
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderWidth = 2
        profilePicture.layer.borderColor = UIColor.lightGray.cgColor
        
        var defaults = UserDefaults.standard
        if defaults.object(forKey: "state") != nil{
            darkModeSwitch.isOn = defaults.bool(forKey: "state")
        }
        
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            if darkModeSwitch.isOn == true {
                appDelegate?.overrideUserInterfaceStyle = .dark
                return
            } else {
                appDelegate?.overrideUserInterfaceStyle = .light
            }
            appDelegate?.overrideUserInterfaceStyle = .light
            return
        }
        
    }
    
    // Change Profile Picture Button
    @IBAction func changePictureButtonPressed(_ sender: Any) {
        presentPhotoActionSheet()
    }
    
    // Change Password Button
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
        // TODO: Implement
        return
    }
    
    // Dark mode slider
    @IBAction func darkModeSlider(_ sender: UISwitch) {
        var defaults = UserDefaults.standard
        
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            if sender.isOn {
                defaults.set(true, forKey: "state")
                appDelegate?.overrideUserInterfaceStyle = .dark
                return
            } else {
                defaults.set(false, forKey: "state")
                appDelegate?.overrideUserInterfaceStyle = .light
            }
            appDelegate?.overrideUserInterfaceStyle = .light
            return
        }
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

// User profile picture implemented here
// TODO: Get profile picture to stay
// TODO: Connect to user profile via firebase
extension IndividualSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let controller = UIAlertController(
                        title: "Profile Picture",
                        message: "Take new profile picture or select from library",
                        preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "Cancel",
                                           style: .cancel,
                                           handler: nil))
        controller.addAction(UIAlertAction(title: "Take Photo",
                                           style: .default,
                                           handler: { [weak self] _ in
            self?.presentCamera()
        }))
        controller.addAction(UIAlertAction(title: "Choose Photo",
                                           style: .default,
                                           handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(controller, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.profilePicture.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
