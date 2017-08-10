//
//  LoginViewController.swift
//  NiaNow
//
//  Created by David Brownstone on 25/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var loginRegisterSegmentedCtrl: UISegmentedControl!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var phoneNoTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var imageBottomAnchor: NSLayoutConstraint!
    
    var returnSegueId = "returnToClasses"

    var tapImage: UITapGestureRecognizer?
    var classesTVController: ClassesTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullNameTextField.delegate = self
        phoneNoTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginRegisterSegmentedCtrl.isHidden = false
        loginRegisterButton.isHidden = true
        
        tapImage = UITapGestureRecognizer(target: self,
                                          action: #selector(handleSelectProfileImageView))
        profileImageView.addGestureRecognizer(tapImage!)    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func handleLoginRegisterChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            handleChangeToLogin()
        } else {
            loginRegisterButton.setTitle("Register", for: .normal)
            handleChangeToRegister()
        }
    }    
    
    func handleChangeToRegister(){
        fullNameTextField.isHidden = false
        phoneNoTextField.isHidden = false
//        imageBottomAnchor.constant = -22
        tapImage = UITapGestureRecognizer(target: self,
                                          action: #selector(handleSelectProfileImageView))
        profileImageView.addGestureRecognizer(tapImage!)
    }
    
    func handleChangeToLogin() {
        fullNameTextField.isHidden = true
        phoneNoTextField.isHidden = true
//        imageBottomAnchor.constant = -15
        if tapImage != nil {
            profileImageView.removeGestureRecognizer(tapImage!)
        }
    }
    
    @IBAction func handleLoginRegister(_ sender: UIButton) {
        if fullNameTextField.isHidden {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text?.isEmpty)! {
            return false
        }
        textField.resignFirstResponder()
        loginRegisterButton.setTitle("Login", for: .normal)
        if fullNameTextField.isHidden == false {
            loginRegisterButton.setTitle("Register", for: .normal)
        }
        switch textField {
        case fullNameTextField:
            phoneNoTextField.becomeFirstResponder()
            break
        case phoneNoTextField:
            emailTextField.becomeFirstResponder()
            break
        case emailTextField:
            let emailAddress = textField.text
            let ref = Database.database().reference().child("users")
            ref.observe(.value, with: { snapshot in
                for aUser in snapshot.children {
                    let member = User(snapshot: aUser as! DataSnapshot)
                    var profileImageUrl:String?
                    if member.email == emailAddress {
                        profileImageUrl = member.profileImageUrl
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl!)
                        break
                    }
                }
            })
            passwordTextField.becomeFirstResponder()
            break
        default: //passwordTextField
            loginRegisterSegmentedCtrl.isHidden = true
            loginRegisterButton.isHidden = false
            break;
        }
        return true
    }
}
