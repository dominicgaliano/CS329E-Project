//
//  changePasswordViewController.swift
//  CS329E-Project
//
//  Created by Ray Zhang on 11/16/22.
//

import UIKit
import FirebaseAuth

class changePasswordViewController: UIViewController {


    
    @IBOutlet weak var errorLab: UILabel!
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLab.text = ""

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
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func changePasswordPressed(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: emailField.text!){ (error) in
            if let error = error{
                self.errorLab.text = error.localizedDescription
            }else{
                self.errorLab.text = ""
                let confirmAlertController = UIAlertController(
                    title: "Success!",
                    message: "Please check your email for further instructions to reset your password",
                    preferredStyle: .alert
                )
                confirmAlertController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default){ (action:UIAlertAction!) in
                        self.dismiss(animated: true, completion: nil)
                    })
                self.present(confirmAlertController,animated:true)
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
