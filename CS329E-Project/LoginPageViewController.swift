//
//  LoginPageViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseAuth

class LoginPageViewController: UIViewController, UITextFieldDelegate {

    // Define outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    // TODO: Remove errorLabel and replace with alert
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make password entry hidden
        passwordField.isSecureTextEntry = true
        
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
    
    // Login button actions
    @IBAction func loginButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) {
            authResult, error in
            if let error = error as NSError? {
                self.errorLabel.text = "\(error.localizedDescription)"
            } else {
                self.errorLabel.text = ""
            }
        }
    }
    
    // Create account button actions
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "createAccountSegue", sender: nil)
    }
    
    // Forgot password button actions
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        // TODO: Implement forgot password features
        return
    }
}
