//
//  CreateAccountViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    // Define outlets
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField:UITextField!
    // TODO: Replace with alert
    @IBOutlet weak var errorLabel: UILabel!
    
    // establish db connection
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addIcon()
        
        // Hide password fields
        passwordField.isSecureTextEntry = true
        repeatPasswordField.isSecureTextEntry = true
        
        // Create login listener
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            if user != nil {
                // performs segue from this VC
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                
                // set textFields to empty
                self.emailField.text = nil
                self.passwordField.text = nil
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.text = ""
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Create account button action
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        // check that name fields not empty
        if !firstNameField.hasText || !lastNameField.hasText {
            displayError(errorMessage: "Missing name field")
        }
        // check if password fields match
        else if passwordField.text! == repeatPasswordField.text! {
            // allow firebase api to verify if email is valid
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
                authResult, error in
                if let error = error as NSError? {
                    // an error occured, alert the user
                    self.displayError(errorMessage: "\(error.localizedDescription)")
                } else {
                    // no error occured, continue
                    self.saveUser(uid: authResult!.user.uid,
                                  firstName: self.firstNameField.text!,
                                  lastName: self.lastNameField.text!,
                                  email: authResult!.user.email!)
                    
                    self.errorLabel.text = ""
                }
            }
        } else {
            displayError(errorMessage: "Passwords must match")
        }
    }
    
    // Cancel button action
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    // Save user to database
    func saveUser(uid: String, firstName: String, lastName: String, email: String) -> Void {
        db.collection("users").document(uid).setData( [
            "uid": uid,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "profilePictureURL": "",
        ]) {err in
            if let err = err {
                self.displayError(errorMessage: "Error saving user info: \(err)")
            } else {
                print("User document added with id \(uid)")
            }
        }
    }
    
    func displayError(errorTitle: String = "Error", errorMessage: String, unwind: Bool = false) {
        let errorController = UIAlertController (
            title: errorTitle,
            message: errorMessage,
            preferredStyle: .alert)
        errorController.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: { action in
                if unwind {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }))
        present(errorController, animated: true)

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
