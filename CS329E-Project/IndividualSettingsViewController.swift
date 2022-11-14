//
//  IndividualSettingsViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage

class IndividualSettingsViewController: UIViewController {

    // Profile picture outlet
    @IBOutlet weak var profilePicture: UIImageView!
    
    // switch status outlet
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    // db connection
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserProfilePicture()
        
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor.lightGray.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
        
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
    
    // get user profile picture
    func getUserProfilePicture() -> Void {
        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var profilePictureURL = document.data()?["profilePictureURL"]
                if profilePictureURL != nil {
                    // TODO: replace profile picture with downloaded picture
                    print("Profile picture URL: \(profilePictureURL)")
                } else {
                    profilePictureURL = ""
                }
            } else {
                print("Document does not exist")
            }
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
    
    // delete account button
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
                        title: "Confirm Account Deletion",
                        message: "Are you sure you want to delete your account? This action cannot be undone",
                        preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: {
            (action: UIAlertAction!) in (self.performAccountDeletion())
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(controller, animated: true)
    }
        
    // deletion account
    func performAccountDeletion() {
        // get user info
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        // delete user data
        deleteUserData(uid)
        
        // delete user
        deleteUser()
        
//        // get users groups
//        removeAllUserGroups(uid)
//
//        // delete users db document
//        deleteUserDocument(uid)
    }
    
    func deleteUserData(_ uid: String) {
        // remove user from all groups
        removeAllUserGroups(uid)
        
        // remove user document and logout
        deleteUserDocument(uid)
    }
    
    func deleteUser() {
        Auth.auth().currentUser!.delete { error in
            if let error = error {
                if AuthErrorCode.Code(rawValue: error._code) == .requiresRecentLogin {
                    // reauthenticate()
                    print("need to reauthenticate")
                } else {
                    print("An unknown error has occured: \(error)")
                }
                return
            }
            
            // logout
            self.performLogout()
        }
    }
    
    // gets users groups and removes them from those groups
    func removeAllUserGroups(_ uid: String) {
        db.collection("users").document(uid)
            .collection("groups").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.performLogout()
                } else {
                    for document in querySnapshot!.documents {
                        let groupID = document.documentID
                        
                        // remove user from group
                        self.removeUserFromGroup(uid, groupID)
                    }
                }
            }
    }
    
    // removes user from group
    func removeUserFromGroup(_ uid: String, _ groupID: String) {
        let groupRef = db.collection("groups").document(groupID)
        
        groupRef.getDocument { [self] (document, error ) in
            if let document = document, document.exists {
                
                
                // check if group has users list (it should)
                if document.data()!["users"] != nil {
                    let oldUsersList:[String] = (document.data()!["users"] as? [String])!
                    
                    // filter uid from list and update
                    let newUsersList:[String] = oldUsersList.filter { $0 != uid }
                    
                    if newUsersList != [] {
                        groupRef.updateData([
                            "users": newUsersList
                        ])
                    } else {
                        // user was the last one in the group
                        self.deleteGroup(groupID)
                    }
                }
            }
        }
    }
    
    func deleteUserDocument(_ uid: String) {
        db.collection("users").document(uid).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("User \(uid) document deleted!")
            }
        }
    }
    
    func deleteGroup(_ groupID: String) {
        // delete subcollection data
        db.collection("users").document(Auth.auth().currentUser!.uid)
            .collection("groups").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.performLogout()
                } else {
                    for document in querySnapshot!.documents {
                        // delete document
                        document.reference.delete() { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Removed document: \(document.documentID)")
                            }
                        }
                    }
                }
            }
        
        // delete document data
        db.collection("groups").document(groupID).delete() { err in
            if let err = err {
                print("Error removing document \(err)")
            } else {
                print("Group documented deleted")
            }
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
        
        // save selected image
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        // save to firestore
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {return}
        let profilePictureReference = Storage.storage().reference().child("\(uid).jpg")
        let uploadTask = profilePictureReference.putData(imageData, metadata: nil) {(metadata, error) in
            profilePictureReference.downloadURL { (url, error ) in
                guard let downloadURL = url else {
                    // error occured
                    return
                }
                // Save download URL to user's data
                let userRef = self.db.collection("users").document(uid)
                userRef.updateData([
                    "profilePictureURL": downloadURL
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            }
        }
        
        // can use this to implement a progress bar if we want
        let observer = uploadTask.observe(.progress) { snapshot in
            print(snapshot.progress?.fractionCompleted ?? "")
        }
        
        
        // finally, change image to newly selected image
        self.profilePicture.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
