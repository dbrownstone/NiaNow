//
//  NiaClassViewController.swift
//  NiaNow
//
//  Created by David Brownstone on 6/5/17.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import Foundation
import UIKit
import Firebase

/**
 this view controller shows information about all the participants in the selected class
 */
class NiaClassViewController: UITableViewController {
    
    var returnSequeId = "goBack"
    var addUserSequeId = "addUser"
    
    var loginViewController:LoginViewController?
    
    var profileImageView = UIImageView()
    
    var selectedClass : NiaClass!
    var members = [User]()
    var user:User!
    var theseMembers = [User]()
    
    var newMember: User?
    var currentUser: User?
    
    var currentCreateAction:UIAlertAction!
    
    var isEditingMode = false
    
    let usersRef = Database.database().reference(withPath: "users")
    var currentUsers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButton = UIBarButtonItem(image: UIImage(named:"backButton"), style: .plain, target: self, action: #selector(closeView))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    func closeView() {
        performSegue(withIdentifier: returnSequeId, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.selectedClass.name
        
        // get the members of this specific class
        usersRef.observe(.value, with: { snapshot in
            var newMembersList:[User] = []
            for aUser in snapshot.children {
                let member = User(snapshot: aUser as! DataSnapshot)
                self.theseMembers.append(member)
                let name = member.name
                let email = member.email
                let phone = member.phoneNo
                let uid = member.uid
                let profileImageUrl = member.profileImageUrl
                for memberId in self.selectedClass.members {
                    // if the user is in the selected class, add to members list
                    if uid == memberId {
                        let attendee = User(name: name!, phoneNo: phone!, email: email!, profileImageUrl: profileImageUrl!)
                        attendee.uid = uid
                        newMembersList.append(attendee)
                        break
                    }
                }
            }
            self.members = newMembersList
            self.tableView.reloadData()
        })
    }
    
    // MARK: - User Actions -
    
    /**
     determines whether to display an action sheet showing the names of all the existing users and a button to add a new member
     */
    @IBAction func didClickOnAddMemberToClass(_ sender: AnyObject) {
        
        performSegue(withIdentifier: addUserSequeId, sender: self)
    }
    
    // MARK: - UITableViewDataSource -
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let member = members[indexPath.row]
        let membersName = cell?.viewWithTag(10) as! UILabel
        let membersPhoneNumber = cell?.viewWithTag(11) as! UILabel
        let membersImage = cell?.viewWithTag(20) as! UIImageView
        
        if members[indexPath.row].name == self.currentUser?.name {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .disclosureIndicator
        }
        
        if self.selectedClass.addedByUser == member.uid {
            membersName.text = "\(String(describing: (member.name)!))(T)"
        } else {
            membersName.text = member.name
        }
        membersPhoneNumber.text = member.phoneNo
        
        membersImage.contentMode = .scaleAspectFit
        membersImage.layer.cornerRadius = (cell?.frame.size.height)! / 2
        membersImage.clipsToBounds = true
        if let profileImageUrl = member.profileImageUrl {
            membersImage.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            membersImage.layer.cornerRadius = membersImage.frame.size.width/2
            membersImage.clipsToBounds = true
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let memberToBeRemoved = self.members[indexPath.row]
            
            
        }
        let replaceAction = UITableViewRowAction(style: .default, title: "Change Image") { (replaceAction, indexPath) -> Void in
            
            let memberToBeModified = self.members[indexPath.row]
            self.handleSelectProfileImageView()
            self.replaceUsersImage(user:memberToBeModified)
            
        }
        replaceAction.backgroundColor = UIColor.green
        return [deleteAction,replaceAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thisMember = members[indexPath.row]
        if thisMember.name! != self.currentUser?.name {
            showChatControllerForUser(members[indexPath.row])
        }
    }
    
    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @IBAction func unwindToNiaClass(segue:UIStoryboardSegue) {
        let controller = segue.source as! NewMemberViewController
        self.selectedClass = controller.theClass
        members.append(self.newMember!)
        //        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addUser" {
            let controller = segue.destination as! NewMemberViewController
            controller.theClass = selectedClass
            controller.currentUser = self.currentUser
        }
    }
    
}
