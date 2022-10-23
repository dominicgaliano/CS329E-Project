//
//  CreateGroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit

public var users = ["hans", "ray", "dominic", "cruz"]

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var memberName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var delegate:UIViewController!
    
    //var addedMembers: [String] = []
    var addedMembers = ["hans", "ray"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationBarPlus()

    }
    
    func navigationBarPlus(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Create Group", style: .plain, target: self, action: #selector(createButton))
    }
    
    @objc public func createButton(){
        if groupName.text == ""{
            let controller = UIAlertController(
                title: "Error",
                message: "Please add a group name",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK", style: .default))
            present(controller, animated: true)
        }
        else if groups.contains(groupName.text!){
            let controller = UIAlertController(
                title: "Error",
                message: "Group name already in use",
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(
                title: "OK", style: .default))
            present(controller, animated: true)
        }
        else{
            performSegue(withIdentifier: "CreateGroupSegueBack", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateGroupSegueBack",
            let nextVC = segue.destination as? GroupSelectorViewController{
                nextVC.addGroup(newGroup: groupName.text!)
        }
    }
    
    
    @IBAction func addMemberButton(_ sender: Any) {
        if memberName.text != ""{
            if addedMembers.contains(memberName.text!){
                let controller = UIAlertController(
                    title: "Error",
                    message: "This user is already added",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                    title: "OK", style: .default))
                present(controller, animated: true)
            }
            else if users.contains(memberName.text!){
                addedMembers.append(memberName.text!)
                self.tableView.reloadData()
            }
            else{
                let controller = UIAlertController(
                    title: "Error",
                    message: "This user does not exist",
                    preferredStyle: .alert)
                controller.addAction(UIAlertAction(
                    title: "OK", style: .default))
                present(controller, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addedMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath)
        cell.textLabel?.text = addedMembers[row]
        
        return cell
    }
}
