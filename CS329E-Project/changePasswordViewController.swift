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
        //Adding unique font
        UILabel.appearance().substituteFontName = "Avenir Next";
        UITextView.appearance().substituteFontName = "Avenir Next";
        UITextField.appearance().substituteFontName = "Avenir Next";
        UIButton.appearance().substituteFontName = "Avenir Next";
        
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
}
extension UILabel {
    @objc var substituteFontName : String {
        get {
            return self.font.fontName;
        }
        set {
            let fontNameToTest = self.font.fontName.lowercased();
            var fontName = newValue;
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold";
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium";
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light";
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight";
            }
            self.font = UIFont(name: fontName, size: self.font.pointSize)
        }
    }
}

extension UITextView {
    @objc var substituteFontName : String {
        get {
            return self.font?.fontName ?? "";
        }
        set {
            let fontNameToTest = self.font?.fontName.lowercased() ?? "";
            var fontName = newValue;
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold";
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium";
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light";
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight";
            }
            self.font = UIFont(name: fontName, size: self.font?.pointSize ?? 17)
        }
    }
}

extension UITextField {
    @objc var substituteFontName : String {
        get {
            return self.font?.fontName ?? "";
        }
        set {
            let fontNameToTest = self.font?.fontName.lowercased() ?? "";
            var fontName = newValue;
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold";
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium";
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light";
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight";
            }
            self.font = UIFont(name: fontName, size: self.font?.pointSize ?? 17)
        }
    }
}
extension UIButton {
    @objc var substituteFontName : String {
        get {
            return self.titleLabel?.font?.fontName ?? "";
        }
        set {
            let fontNameToTest = self.titleLabel?.font?.fontName ?? "";
            var fontName = newValue;
            if fontNameToTest.range(of: "bold") != nil {
                fontName += "-Bold";
            } else if fontNameToTest.range(of: "medium") != nil {
                fontName += "-Medium";
            } else if fontNameToTest.range(of: "light") != nil {
                fontName += "-Light";
            } else if fontNameToTest.range(of: "ultralight") != nil {
                fontName += "-UltraLight";
            }
            self.titleLabel?.font = UIFont(name: fontName, size: self.titleLabel?.font?.pointSize ?? 17)
        }
    }
}

