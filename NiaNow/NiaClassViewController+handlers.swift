//
//  NiaClassViewController+handlers.swift
//  NiaNow
//
//  Created by David Brownstone on 31/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit
import Firebase

extension NiaClassViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    func replaceUsersImage(user:User) {
        let imagename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imagename).png")
        
        if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            storageRef.putData(uploadData, metadata: nil, completion: {(metadata,error) in
                
                if error != nil {
                    print(error ?? "Unable to load into Firebase Storage")
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    user.profileImageUrl = profileImageUrl
                Database.database().reference().child("users").child(user.uid!).setValue(["name": user.name, "phoneNo": user.phoneNo, "email": user.email, "profileImageUrl": profileImageUrl])
                    
                    let temp = self.members
                    self.members = []
                    for member in temp {
                        if member.uid == user.uid {
                            self.members.append(user)
                        } else {
                            self.members.append(member)
                        }
                    }
                    self.tableView.reloadData()
                }
            })
        }

    }
    
    func handleSelectProfileImageView() {
        
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
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled picker")
        dismiss(animated: true, completion: nil)
    }
}
