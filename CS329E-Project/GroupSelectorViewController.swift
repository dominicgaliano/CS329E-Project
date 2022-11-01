//
//  GroupSelectorViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit

protocol groupAdder{
    func addGroup(newGroup:String)
}

public var groups = ["group1", "group2", "group3"]
class GroupSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, groupAdder{

    @IBOutlet weak var tableView: UITableView!
    var delegate:UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        cell.textLabel?.text = groups[row]
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateGroupSegue",
            let nextVC = segue.destination as? CreateGroupViewController{
                nextVC.delegate = self
         
        }
    }
    
    func addGroup(newGroup: String) {
        groups.append(newGroup)
        //self.tableView.reloadData()
    }
}
