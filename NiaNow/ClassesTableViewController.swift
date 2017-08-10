//
//  ClassesTableViewController.swift
//  NiaNow
//
//  Created by David Brownstone on 25/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell

/**
 If a user is currently logged in, this controller displays all of the classes applicable for the logged-in user. Sliding a class name to the left connects this user to the class chat screen, while sliding the class name to the right allows the user to remove this class from the display
 If there is no logged-in user, the controller displays a login screen
*/
class ClassesTableViewController: UITableViewController {

    // segue ids
    var loginToNiaNow = "toLogin"
    var unwindSegueId = "returnToClasses"
    var showMembersSegueId = "showMembers"
    
    let loadingView = UIView()
    let loadingLabel = UILabel()
    let spinner = UIActivityIndicatorView()
    
    /// the currently logged-in member
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Determines whether a user is currently logged in. If not, the login screen is displayed otherwise, the user's name is displayed in the title
     and all the classes of which the current user is a member or teacher, are displayed.
    */
    func checkIfUserIsLoggedIn() {
        let currentUserId = Auth.auth().currentUser?.uid
        if currentUserId == nil {
            perform(#selector(handleLoginRegister), with: nil, afterDelay:0)
        } else {
            // display the spinner (activityIndicator)
            self.setLoadingScreen()
            // set the nav bar title
            setNavTitle(currentUserId!)
        }
    }

    /**
     extracts the currently logged-in user's information and displays the name in the nav bar
     
     - Parameter currentUserId: the UDID string of the currently logged-in member
    */
    func setNavTitle(_ currentUserId: String) {
        let ref = Database.database().reference().child("users")
        ref.observe(.value, with: { snapshot in
            for aUser in snapshot.children {
                let member = User(snapshot: aUser as! DataSnapshot)
                if member.uid == currentUserId {
                    self.currentUser = member
                    self.navigationItem.title = member.name
                    // extract all the appriate classes from Firebase
                    self.getAllClasses()
                    break
                }
            }
        })
    }
    
    var existingClasses:[NiaClass]?
    var classesDictionary = [String: NiaClass]()
    
    /**
     extracts all the Nia Classes of which the currently logged-in user is either a member or the teacher. Note: **User** stores both the teacher and other members in its list of members!
    */
    func getAllClasses() {
         Database.database().reference().child("classes").observe(.value, with: { snapshot in
            var newClasses: [NiaClass] = []
            for aClass in snapshot.children {
                let niaClass = NiaClass(snapshot: aClass as! DataSnapshot)
                //select only the appropriate classes
                if niaClass.members.contains((self.currentUser?.uid!)!) {
                    newClasses.append(niaClass)
                }
            }
            self.existingClasses = newClasses
            self.tableView.reloadData()
            self.spinner.stopAnimating()
            self.loadingLabel.isHidden = true
            
        })
    }
    
    /**
     Adds a new class with the current member as the originator i.e. teacher and member
     */
    @IBAction func addAClass(_ sender: UIBarButtonItem) {
        displayAlertToAddClass()
    }
    
    /**
     If the app is running, either in the foreground, or the background, when a notification arrives, this function determines how to handle it i.e. which screen to display
     
     - Parameter aps: dictionary of data from the push notification
        1. aps["chat"] could have value of "class" if Class Chat is requested or "one-on-one" if individual chat is required
        2. aps["toId"] specifies the UDID string of the specific class or the receiving user
    */
    public func handleNotification(_ aps:[String: AnyObject]) {
        if aps["chat"] as! String == "class" {
            for thisClass in existingClasses! {
                if thisClass.uid == aps["toId"] as! String {
                    self.showChatControllerForGroup(thisClass, notificationInfo:aps)
                }
            }
        } else {
            //TODO: complete the one-on-one notification
            // "one-on-one"
        }
    }
    
    /**
     opens the login screen
    */
    func handleLoginRegister() {
        performSegue(withIdentifier: self.loginToNiaNow, sender: self)
    }
    
    /**
     presents an alert to add a new class by name
    */
    func displayAlertToAddClass(){
        let title = "New Nia Class"
        let doneTitle = "Save"
        
        let alertController = UIAlertController(title: title, message: "Enter the name of this Nia Class.", preferredStyle: UIAlertControllerStyle.alert)
        let saveAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            guard let textField = alertController.textFields?.first, let text = textField.text else { return }
            let niaClass = NiaClass(name: textField.text!,
                                    addedByUser: (Auth.auth().currentUser?.uid)!)
            let niaClassRef = Database.database().reference().child("classes").child(niaClass.uid)
            niaClassRef.setValue(niaClass.toAnyObject())
        }
        
        alertController.addAction(saveAction)
        saveAction.isEnabled = true
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        })
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Enter the Name of this Nia Class"
        }
        
        self.present(alertController, animated: true, completion: nil)
    }

    /**
     creates a view of a label and an spinning activityIndicator
    */
    private func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.tableView.frame.width / 2) - (width / 2)
        let y = (self.tableView.frame.height / 2) - (height / 2) - (self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x:x, y:y, width:width, height:height)
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = .center
        self.loadingLabel.text = "Loading..."
        self.loadingLabel.frame = CGRect(x:0, y:0, width:140, height:30)
        
        // Sets spinner
        self.spinner.activityIndicatorViewStyle = .gray
        self.spinner.frame = CGRect(x:0, y:0, width:30, height:30)
        self.spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        
        self.tableView.addSubview(loadingView)
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = existingClasses?.count {
            return count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MGSwipeTableCell
        let thisClass = existingClasses?[indexPath.row]
        
        // Configure the cell...
        cell.leftButtons = [MGSwipeButton(title: "Class Chat", backgroundColor: UIColor.themeBubbleBlueColor, callback: {(_ MGSwipeTableCell) -> Bool in
            print("chat button tapped")
            self.showChatControllerForGroup(thisClass!)
            return true
        })]
        cell.rightButtons = [MGSwipeButton(title: "Remove\nThis Class", backgroundColor: UIColor.purple, callback: {(_ MGSwipeTableCell) -> Bool in
            print("Delete button tapped")
            return true
        })]
        
        
        cell.textLabel?.text = thisClass?.name
        cell.detailTextLabel?.text = "Member Count: \(thisClass!.numberOfUsers())"
        return cell
    }
    
    func showChatControllerForGroup(_ group:NiaClass, notificationInfo:[String: AnyObject] = [:]) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.thisClass = group
        if !notificationInfo.isEmpty {
            chatLogController.notificationInfo = notificationInfo
        }
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    var selectedClass:NiaClass?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedClass = existingClasses?[indexPath.row]
        performSegue(withIdentifier: "showMembers", sender: self)

    }

    @IBAction func handleLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        performSegue(withIdentifier: self.loginToNiaNow, sender: self)
    }
    
    // MARK: - Navigation

    @IBAction func unwindToClasses(segue:UIStoryboardSegue) {
        if segue.identifier == unwindSegueId {
            let currentUserId = Auth.auth().currentUser?.uid
            setNavTitle(currentUserId!)
            Database.database().reference().observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.hasChild("classes"){
                    print("classes exist")
                    self.getAllClasses()
                } else {
                    self.displayAlertToAddClass()
                }
                
                
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        if segue.identifier == showMembersSegueId {
            let controller = navController.topViewController as! NiaClassViewController
            controller.selectedClass = selectedClass
            controller.currentUser = currentUser
        } else if segue.identifier == loginToNiaNow {
            let controller = navController.topViewController as! LoginViewController
            controller.classesTVController = self
        }
    }
    

}
