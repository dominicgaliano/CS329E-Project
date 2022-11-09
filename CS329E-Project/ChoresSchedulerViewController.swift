//
//  ChoresSchedulerViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit

class Chore{
    var name:String
    var date:Date
    var person:String
    var replicate: Bool
    init(name:String = "", date:Date = Date(),person:String = "", replicate: Bool = false){
        self.name = name
        self.date = date
        self.person = person
        self.replicate = replicate
    }
}

protocol sendChore{
    func addChore(newChore: Chore)
}

class ChoresSchedulerViewController: UIViewController {
    
    var delegate: sendChore? = nil
    var newChore = Chore()
    

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var choreLab: UITextField!
    
    @IBOutlet weak var personLab: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var replicateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func choreButtonPressed(_ sender: Any) {
        if choreLab.text == nil || personLab.text == nil{
            statusLabel.text = "You didn't fill out everything!"
        }else{
            newChore.name = choreLab.text!
            newChore.person = personLab.text!
            newChore.date = datePicker.date
            if replicateSwitch.isOn{
                newChore.replicate = true
            }else{
                newChore.replicate = false
            }
        }
        self.delegate?.addChore(newChore: newChore)
        print("hi")
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
