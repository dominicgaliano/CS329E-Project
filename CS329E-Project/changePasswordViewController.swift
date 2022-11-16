//
//  changePasswordViewController.swift
//  CS329E-Project
//
//  Created by Ray Zhang on 11/13/22.
//

import UIKit
import FirebaseAuth
import Firebase

class changePasswordViewController: UIViewController {
    
    //define outlets

    @IBOutlet weak var emailLab: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func changePasswordPressed(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: emailLab.text!){ (error) in
            if let error = error{
                self.errorLabel.text = error.localizedDescription
            }else{
                self.errorLabel.text = ""
                self.dismiss(animated: true, completion: nil)
            }
                
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
