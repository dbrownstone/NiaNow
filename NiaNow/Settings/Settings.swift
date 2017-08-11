//
//  Settings.swift
//  NiaNow
//
//  Created by David Brownstone on 10/08/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit

class Settings: UITableViewController {

    var conversationLimitSegue = "showConversationLimit"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:.subtitle, reuseIdentifier: "subtitle")

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Class Messages"
            cell.detailTextLabel?.text = "30 days"
        default:
            cell.textLabel?.text = "One-on-one Messages"
            cell.detailTextLabel?.text = "7 days"
        }

        return cell
    }
    
    @IBAction func unwindToSettings(segue:UIStoryboardSegue) {
        if segue.identifier == "unwindSegueId" {
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "showChatConversationLimit", sender: self)
            default:
                self.performSegue(withIdentifier: "showSinglesConversationLimit", sender: self)
            }
        default:
            return
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination
        if segue.identifier == "showChatConversationLimit" {
            (controller as! ChatLimits).modeClass = true
        } else if segue.identifier == "showSinglesConversationLimit" {
            (controller as! ChatLimits).modeClass = false
        }
    }

}
