//
//  User.swift
//  NiaNow
//
//  Created by David Brownstone on 25/07/2017.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import UIKit
import Firebase

class User: NSObject {
    
    var uid:String?
    var name:String?
    var phoneNo: String?
    var email:String?
    var profileImageUrl:String?
    
    override init() {
        super.init()
    }
    
    init(name: String, phoneNo: String, email: String, profileImageUrl: String) {
        self.name = name
        self.phoneNo = phoneNo
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
    
    init(snapshot: DataSnapshot) {
        uid = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as? String
        self.phoneNo = snapshotValue["phoneNo"] as? String
        self.email = snapshotValue["email"] as? String
        self.profileImageUrl = snapshotValue["profileImageUrl"] as? String
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "phoneNo": phoneNo,
            "email": email,
            "profileImageUrl": profileImageUrl
        ]
    }
}
