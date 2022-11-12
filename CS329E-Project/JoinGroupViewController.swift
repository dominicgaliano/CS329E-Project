//
//  JoinGroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit

protocol fillGroupCode{
    func updateTextField(code:String)
}

class JoinGroupViewController: UIViewController, fillGroupCode {
    
    @IBOutlet weak var joinGroupName: UITextField!
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScannerSegue",
            let nextVC = segue.destination as? ScannerViewController{
                nextVC.delegate = self
        }
    }
    
    @IBAction func joinGroupButton(_ sender: Any) {
        if groups.contains(joinGroupName.text!) == false{
            let controller = UIAlertController(
                title: "Error",
                message: "This group does not exist",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK", style: .default))
            present(controller, animated: true)
        }
        else{
            performSegue(withIdentifier: "JoinGroupSegueBack", sender: nil)
        }
    }
    
    func updateTextField(code: String) {
        joinGroupName.text = code
    }
}
