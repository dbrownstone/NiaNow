//
//  LoginViewController+handlers.swift
//  NiaNow
//
//  Created by David Brownstone on 25/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit
import Firebase

/**
 Handles profile image access, registering a new user and logging in an existing user
 */
extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    /**
     creates and logs in a new user
    */
    func handleRegister() {
             guard let email = emailTextField.text, let password = passwordTextField.text, let name = fullNameTextField.text, let phone = phoneNoTextField.text else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user,error) in
            if error != nil {
                print(error ?? "")
                self.showAlert((error?.localizedDescription)!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            //need to check for the existence in "users" of this email - if so, replace the firebase-generated uid with the new existing uid (in users)
            //auth.uid.replace()
            let userRef = Database.database().reference().child("users")
            userRef.observe(.value, with: { snapshot in
                for aUser in snapshot.children {
                    let member = User(snapshot: aUser as! DataSnapshot)
                    if member.email == email {
                        if member.uid != uid {
                            self.replaceCurrent(member.uid!, withId: uid, imageUrl: member.profileImageUrl!)
                            self.performSegue(withIdentifier: "returnToClasses", sender: self)
                            return
                        } else {
                            if (!(member.profileImageUrl?.isEmpty)!) {
                                return
                            }
                            // successfully authenticated user
                            let imagename = NSUUID().uuidString
                            let storageRef = Storage.storage().reference().child("profile_images").child("\(imagename).png")
                            
                            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                                storageRef.putData(uploadData, metadata: nil, completion: {(metadata,error) in
                                    
                                    if error != nil {
                                        print(error ?? "Unable to load into Firebase Storage")
                                        self.showAlert((error?.localizedDescription)!)
                                        return
                                    }
                                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                                        let values = ["name" : name, "phoneNo": phone, "email" : email, "profileImageUrl": profileImageUrl] as [String : AnyObject]
                                        self.registerUserIntoDatabaseWithUID(uid:uid,values:values as [String : AnyObject])
                                    }
                                })
                            }
                        }
                    }
                    
                }
                
                self.performSegue(withIdentifier: self.returnSegueId, sender: self)
            })
        })
    }
    
    /**
     adds a new user to the "users" Firestone database
     
     - Parameter uid: new user's udid
     - Parameter values: Dictionary of all the user values - email, name, phone number ...
     */
    public func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference(fromURL: "https://nianow-a5d5b.firebaseio.com/")
        let usersRef = ref.child("users").child(uid)
        //
        usersRef.updateChildValues(values, withCompletionBlock: {(err, ref) in
            if err != nil {
                print(err ?? "")
                self.showAlert((err?.localizedDescription)!)
                return
            }
            let user = User()
            //this setter potentially crashes if keys don't match
            user.setValuesForKeys(values)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    /**
     displays the system Image Picker
     */
    func handleSelectProfileImageView() {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
 
    /**
     UIImagePickerControllerDelegate method to select the picked image
     
     - Parameter picker: the UIImagePickerController
     - Parameter: info: dictionary of image values
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    /**
     UIImagePickerControllerDelegate method to cancel image selection
     
     - Parameter picker: the UIImagePickerController
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled picker")
        dismiss(animated: true, completion: nil)
    }
    
    /**
     logs in an already existing user and displays the matching  profile image
     */
    func handleLogin() {
        self.classesTVController?.navigationItem.titleView = nil
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Invalid login parameters!")
            self.showAlert("Incomplete text fields!")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error ?? "Error signing in")
                self.showAlert((error?.localizedDescription)!)
                return
            }
            self.performSegue(withIdentifier: "returnToClasses", sender: self)
        })
    }
    
    /**
     replaces the app-generated UDID (at the time of registering, by the Firebase-generated UDID - replaced in the members array fo each class as well as the user in the users database
     */
    func replaceCurrent(_ fromId: String, withId: String, imageUrl: String) {
        let firebase = Database.database().reference()
        
        firebase.child("classes").observe(.value, with: { snapshot in
            for aClass in snapshot.children {
                var niaClass = NiaClass(snapshot: aClass as! DataSnapshot)
                if niaClass.members.contains(fromId) {
                    let index = niaClass.members.index(of: fromId)
                    niaClass.members.remove(at: index!)
                    niaClass.members.insert(withId, at: index!)
                    
                    Database.database().reference().root.child("classes").child(niaClass.uid).updateChildValues(["members": niaClass.members])
                }
                var member:User?
                firebase.child("users").observe(.value, with: { snapshot in
                    for aMember in snapshot.children {
                        let thisMember = User(snapshot: aMember as! DataSnapshot)
                        if thisMember.uid == fromId {
                            member = thisMember
                            member?.profileImageUrl = imageUrl
                            firebase.child("users").child(fromId).removeValue { (error, ref) in
                                if error != nil {
                                    print(error ?? "unable to remove uid")
                                }
                                if member != nil {
                                    firebase.child("users").child(withId).setValue((member!).toAnyObject())
                                }
                            }
                            break
                        }
                    }
                })
                
            }
        })
        
    }
    
    /**
     general alert view for error messages
     
     - Parameter message: the message string to be displayed in the alert
     */
   func showAlert(_ message:String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true){ }
    }
}
