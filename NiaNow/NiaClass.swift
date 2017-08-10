//
//  NiaClass
//  NiaNow
//
//  Created by David Brownstone on 25/7/17.
//  Copyright © 2017 David Brownstone. All rights reserved.
//

import Foundation
import Firebase

struct NiaClass {
    let uid: String
    let name: String
    let addedByUser: String
    var members:[String]
    
    init(name: String, addedByUser: String) {
        self.uid = UUID().uuidString
        self.name = name
        self.addedByUser = addedByUser //uid
        self.members = []
        self.members.append(addedByUser)
    }
    
    init(snapshot: DataSnapshot) {
        uid = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        if snapshotValue["members"] != nil  {
            members = snapshotValue["members"] as! [String]
        } else {
            members = []
            members.append(addedByUser)
        }
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "addedByUser": addedByUser,
            "members": members
        ]
    }
    
    func numberOfUsers() -> Int {
        return self.members.count
    }
    
    mutating func addAMember(id:String) {
        self.members.append(id)
    }
}
