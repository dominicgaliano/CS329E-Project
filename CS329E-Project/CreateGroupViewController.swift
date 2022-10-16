//
//  CreateGroupViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit

class CreateGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var memberName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    //var addedMembers: [String] = []
    var addedMembers = ["hans", "ray", "dominic", "cruz"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationBarPlus()

    }
    
    func navigationBarPlus(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Create Group", style: .plain, target: self, action: nil)
    }
    
    
    @IBAction func addMemberButton(_ sender: Any) {
        if memberName.text != ""{
            addedMembers.append(memberName.text!)
            self.tableView.reloadData()
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
