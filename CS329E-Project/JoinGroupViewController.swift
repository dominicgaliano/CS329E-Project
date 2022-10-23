//
//  JoinGroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit

class JoinGroupViewController: UIViewController {

    @IBOutlet weak var joinGroupName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    

}
