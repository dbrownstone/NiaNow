//
//  Settings.swift
//  NiaNow
//
//  Created by David Brownstone on 10/08/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit

class Settings: UITableViewController {

    var settingsItems = ["Message Availability"]
    
    var chatLimitSegue = "showChatConversationLimit"
    var oneOnOneLimitSegue = "showSinglesConversationLimit"
    
    var classPeriod: String?
    var classPeriodInt: Int?
    var oneOnOnePeriod: String?
    var oneOnOnePeriodInt: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //message availability setting
        let privateMsgTimeSpan = defaults.object(forKey: PrivateMessagesTimeSpan) as! [String: Int]
        let classMsgTimeSpan = defaults.object(forKey: ClassMessagesTimeSpan) as! [String: Int]
        self.classPeriod = ([String](classMsgTimeSpan.keys)).first!
        self.classPeriodInt = classMsgTimeSpan[classPeriod!]!
        self.oneOnOnePeriod = ([String](privateMsgTimeSpan.keys)).first!
        self.oneOnOnePeriodInt = privateMsgTimeSpan[oneOnOnePeriod!]!
        //
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        super.viewWillDisappear(animated)
        
        defaults.synchronize()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        default: //Message Availability
            return 2
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:.subtitle, reuseIdentifier: "subtitle")
        
        switch indexPath.section {
        default: //Message Availability
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Class Messages"
                cell.detailTextLabel?.text = self.classPeriod
            default:
                cell.textLabel?.text = "One-on-one Messages"
                cell.detailTextLabel?.text = self.oneOnOnePeriod
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        default:
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: chatLimitSegue, sender: self)
            default:
                self.performSegue(withIdentifier: oneOnOneLimitSegue, sender: self)
            }
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToSettings(segue:UIStoryboardSegue) {
        if segue.identifier == "returnToSettings" {
            let controller = segue.source as! ChatLimits
            let result = controller.selectedResult
            let theKey = controller.selectedKey
            let selectedDict = controller.selectedDict
            if controller.modeClass {
                self.classPeriod = theKey!
                self.classPeriodInt = result!
                defaults.set(selectedDict, forKey: ClassMessagesTimeSpan)
            } else {
                self.oneOnOnePeriod = theKey!
                self.oneOnOnePeriodInt = result!
                defaults.set(selectedDict, forKey: PrivateMessagesTimeSpan)
            }
            defaults.synchronize()
            self.tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ChatLimits
        if segue.identifier == chatLimitSegue {
            controller.modeClass = true
        } else if segue.identifier == oneOnOneLimitSegue {
            controller.modeClass = false
        }
    }
}
