//
//  CreateAccountViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseAuth

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    // Define outlets
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField:UITextField!
    // TODO: Replace with alert
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide password fields
        passwordField.isSecureTextEntry = true
        repeatPasswordField.isSecureTextEntry = true
        
        // Create login listener
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            if let user = user {
                // save new user to db
                self.saveUser(firstName: self.firstNameField.text!,
                         lastName: self.lastNameField.text!,
                         email: self.emailField.text!,
                         uid: user.uid)
                
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
            errorLabel.text = "Missing name field"
        }
        // check if password fields match
        else if passwordField.text! == repeatPasswordField.text! {
            // allow firebase api to verify if email is valid
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
                authResult, error in
                if let error = error as NSError? {
                    // an error occured, alert the user
                    self.errorLabel.text = "\(error.localizedDescription)"
                } else {
                    // no error occured, continue
                    self.errorLabel.text = ""
                }
            }
        } else {
            self.errorLabel.text = "Passwords must match"
        }
    }
    
    // Cancel button action
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    // Save user to database
    func saveUser(firstName: String, lastName: String, email: String, uid: String) -> Void {
        // TODO: Implement database addition
        print("Saving user \(firstName) \(lastName) with email: \(email) and auto-generated uid: \(uid)")
    }
}
