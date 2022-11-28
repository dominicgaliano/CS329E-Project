//
//  LoginPageViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
import FirebaseAuth

class LoginPageViewController: UIViewController, UITextFieldDelegate {
    
    // dark mode
    var darkMode = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.text = ""
        
        // dark mode
        var defaults = UserDefaults.standard
        if defaults.object(forKey: "state") != nil{
            darkMode = defaults.bool(forKey: "state")
        }
        
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            if darkMode == true {
                appDelegate?.overrideUserInterfaceStyle = .dark
                return
            } else {
                appDelegate?.overrideUserInterfaceStyle = .light
            }
            appDelegate?.overrideUserInterfaceStyle = .light
            return
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
        let loadingVC = loadingViewController()
        
        // Animate loadingVC over the existing views on screen
        loadingVC.modalPresentationStyle = .overCurrentContext
        
        // Animate loadingVC with a fade in animation
        loadingVC.modalTransitionStyle = .crossDissolve
        
        present(loadingVC, animated: true, completion: nil)
        loadingVC.dismiss(animated: true){
            Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) {
                authResult, error in
                if let error = error as NSError? {
                    self.errorLabel.text = "\(error.localizedDescription)"
                } else {
                    self.errorLabel.text = ""
                }
            }
        }
        
    }
    
    
    
    // Create account button actions
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        //create and present loading animation
        let loadingVC = loadingViewController()
        
        
        loadingVC.modalPresentationStyle = .overCurrentContext
        
        
        loadingVC.modalTransitionStyle = .crossDissolve
        
        present(loadingVC, animated: true, completion: nil)
        loadingVC.dismiss(animated: true){
            //only perform segue when the dismissal is complete
            self.performSegue(withIdentifier: "createAccountSegue", sender: nil)
        }
        
    }
    
    // Forgot password button actions
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        //create and present loading animation
        let loadingVC = loadingViewController()
        
        
        loadingVC.modalPresentationStyle = .overCurrentContext
        
        
        loadingVC.modalTransitionStyle = .crossDissolve
        
        present(loadingVC, animated: true, completion: nil)
        loadingVC.dismiss(animated: true){
            //only perform segue when the dismissal is complete
            self.performSegue(withIdentifier: "forgotPasswordSegue", sender: nil)
        }
    }
}
