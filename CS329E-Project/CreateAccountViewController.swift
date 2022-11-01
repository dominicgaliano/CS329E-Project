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
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                self.emailField.text = nil
                self.passwordField.text = nil
            }
        }
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
        if passwordField.text! == repeatPasswordField.text! {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
                authResult, error in
                if let error = error as NSError? {
                    self.errorLabel.text = "\(error.localizedDescription)"
                } else {
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
    
}
