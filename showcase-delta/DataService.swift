//
//  DataService.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/9/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

let URL_BASE = FIRDatabase.database().reference

class DataService {
    static let ds = DataService()
    private var _REF_BASE = URL_BASE
    private var _REF_POSTS = URL_BASE().child("posts")
    private var _REF_USERS = URL_BASE().child("users")
    private var _REF_COMMENTS = URL_BASE().child("comments")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE()
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = URL_BASE().child("users").child(uid)
        return user
      
    }
    
    var REF_COMMENTS: FIRDatabaseReference {
        return _REF_COMMENTS
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String,String>) {
        _REF_USERS.child(uid).updateChildValues(user)
    }

    
}
