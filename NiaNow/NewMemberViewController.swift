//
//  NewMemberViewController.swift
//  NiaNow
//
//  Created by David Brownstone on 27/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit
import Firebase

/**
 register a new class member - 
*/
class NewMemberViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var theClass:NiaClass?
    var currentUser: User?
    var theNewMember: User?
    var profileImageUrl: String?
    var members = [User]()
    
    @IBOutlet weak var newMemberView: UIView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var profileImageView: UIImageView?
    @IBOutlet weak var newMemberName: UITextField!
    @IBOutlet weak var newMemberPhoneNo: UITextField!
    @IBOutlet weak var newMemberEmail: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newMemberName.delegate = self
        newMemberPhoneNo.delegate = self
        newMemberEmail.delegate = self
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        let ref = Database.database().reference().child("users")
        ref.observe(.value, with: { snapshot in
            for aUser in snapshot.children {
                let member = User(snapshot: aUser as! DataSnapshot)
                if member.uid != self.currentUser?.uid {
                    self.members.append(member)
                    self.picker.reloadAllComponents()
                }
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if profileImageView?.image == UIImage(named:"Nia-Logo-250") {
            self.selectImageFromPickerControl(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text?.isEmpty)! {
            return false
        }
        textField.resignFirstResponder()
        switch textField {
            
        case newMemberName:
            self.newMemberPhoneNo.becomeFirstResponder()
            break
        case newMemberPhoneNo:
            self.newMemberEmail.becomeFirstResponder()
            break
        default:
            break
        }
        return true
    }
    
    @IBAction func selectImageFromPickerControl(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.profileImageView?.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled picker")
        dismiss(animated: true, completion: nil)
    }

    var selectedEntry:Int?
    
    /**
     if an existing user is selected, that user is added to the class database otherwise the Register 'New Member Screen' is made visible
     */
    @IBAction func Select(_ sender: Any) {
        if self.selectedEntry == self.members.count {
            self.newMemberView.isHidden = false
            return
        }
        self.theNewMember = self.members[selectedEntry!]
        self.theClass?.addAMember(id: (self.theNewMember?.uid!)!)
        self.updateClassInDatabaseWithUID()
    }
    
    /**
     registers a newly-added member into the users database as well as adding this new user to the list of members in the selected class
     
     - Parameter uid: the UDID string of the newly-created member
     - values: a dictionary containing the UDID of the new member and the UDID of the currentUser - the teacher of this class
     */
    func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference(fromURL: "https://nianow-a5d5b.firebaseio.com/")
        let usersRef = ref.child("users").child(uid)
        //
        usersRef.updateChildValues(values, withCompletionBlock: {(err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
            self.theNewMember = User()
            //this setter potentially crashes if keys don't match
            self.theNewMember?.setValuesForKeys(values)
            self.theClass?.addAMember(id: (self.theNewMember?.uid!)!)
            self.updateClassInDatabaseWithUID()
        })
    }

    /**
     updates the class members list with the id of the added member - whether from a selection of current users or by new user registration
     */
    func updateClassInDatabaseWithUID() {
        let classValues = ["name": self.theClass?.name as Any,"addedByUser": self.theClass?.addedByUser as Any,"members": self.theClass?.members as Any] as [String : Any]
        let ref = Database.database().reference(fromURL: "https://nianow-a5d5b.firebaseio.com/")
        let classRef = ref.child("classes").child((self.theClass?.uid)!)
        
        classRef.updateChildValues(classValues, withCompletionBlock: {(err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
            self.performSegue(withIdentifier: "returnToClass", sender: self.theNewMember)
        })
    }
    
    @IBAction func registerNewMember(_ sender: Any) {
        let memberName = newMemberName.text
        let memberEmail = newMemberEmail.text
        let memberPhone = newMemberPhoneNo.text
        if (memberName?.isEmpty)! || (memberEmail?.isEmpty)! || (memberPhone?.isEmpty)! {
            return
        }
        self.saveImageToFirebase(memberName!, phone: memberPhone!, email: memberEmail!)
}
    
    func saveImageToFirebase(_ name: String, phone: String, email: String) {
        let imagename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imagename).png")
        
        if let profileImage = self.profileImageView?.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            storageRef.putData(uploadData, metadata: nil, completion: {(metadata,error) in
                
                if error != nil {
                    print(error ?? "Unable to load into Firebase Storage")
                    return
                }
                self.profileImageUrl = metadata?.downloadURL()?.absoluteString
                let member = User(name: name, phoneNo: phone, email: email, profileImageUrl: self.profileImageUrl!)
                member.uid = NSUUID().uuidString
                let values = ["uid": member.uid, "name" : member.name, "phoneNo": member.phoneNo, "email" : member.email, "profileImageUrl": member.profileImageUrl] as [String : AnyObject]
                self.registerUserIntoDatabaseWithUID(uid:member.uid!,values:values as [String : AnyObject])
            })
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.members.count + 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == members.count {
            return "Register a New User"
        }
        return members[row].name
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedEntry = row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "returnToClass" {
            let controller = segue.destination as! NiaClassViewController
            controller.newMember = sender as? User
        }
    }

}
