//
//  Comment.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/26/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Comment: Post {
    
    var _commentKey: String!
    var _commentRef: FIRDatabaseReference!
    
    var commentKey: String {
        return self._commentKey
    }
    
    
    var commentRef: FIRDatabaseReference {
        return self._commentRef
    }
    
    override init(description: String, imageUrl: String?) {
        super.init(description: description, imageUrl: "")
    }
    
    override init(key: String, dictionary: Dictionary<String, AnyObject>) {
        super.init(key: (dictionary["postKey"] as? String)! , dictionary: dictionary)
        self._commentKey = key
        self._commentRef = DataService.ds.REF_COMMENTS.child(self._commentKey)
        
    }
    override func adjustLikes(addLike: Bool) {
        if addLike == true {
            super.likes = super.likes + 1
        } else {
            super.likes = super.likes - 1
        }
        
        _commentRef.child("likes").setValue(super.likes)
        
    }
    
}
