//
//  Post.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/14/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Post {
    private var _postDescription: String!
    private var _imageURL: String?
    private var _likes: Int!
    private var _user: User?
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var postDescription: String {
        
        return _postDescription
    }
    
    var imageURL: String? {
        return _imageURL
    }
    
    var likes: Int {
        get {
            return _likes
        }
        set {
            _likes = newValue
        }
        
    }
    
    var user: User? {
        return _user
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imageUrl: String?) {
        self._postDescription = postDescription
        self._imageURL = imageUrl
        
    }
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = key
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imageUrl = dictionary["imageURL"] as? String {
            self._imageURL = imageUrl
        }
        
        if let postDesc = dictionary["description"] as? String {
            self._postDescription = postDesc
        }
        
        if let userkey = dictionary["userKey"] as? String {
            self._user = findUser(userkey)
        }
        
        self._postRef = DataService.ds.REF_POSTS.child(self._postKey)
        
        
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike == true {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
        
    }
        
    func findUser(userkey: String) -> User {
        for user in users {
            if user.userKey ==  userkey {
                return user
            }
        }
        
        return User(username: "Unknown User", userKey: "00000", profileImgUrl: "", userEmail: "", loginType: "")
        
        
    }

    
}
