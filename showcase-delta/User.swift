//
//  User.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/16/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    private var _username: String?
    private var _profileImgUrl: String?
    private var _userKey: String
    private var _userEmail: String?
    private var _loginType: String
    
    var username: String {
        get {
            if _username != nil {
                return _username!
            } else {
                return "New User"
            }
        }
        
    }
    
    var userKey: String {
        return _userKey
    }
    
    var userEmail: String {
        get {
            if _userEmail != nil {
                return _userEmail!
            } else {
                return ""
            }
        }
    }
    
    var profileImgUrl: String {
        get {
            if _profileImgUrl != nil {
                return _profileImgUrl!
            } else {
                return ""
            }
        }
    }
    
    var loginType: String {
        return _loginType
    }
    
    init(userKey:String, loginType: String) {
        self._userKey = userKey
        self._loginType = loginType
    }
    init(username: String, userKey:String, profileImgUrl: String, userEmail: String, loginType: String) {
        self._username = username
        self._userKey = userKey
        self._profileImgUrl = profileImgUrl
        self._userEmail = userEmail
        self._loginType = loginType
    }
    
    init(key: String, dictionary: Dictionary<String,AnyObject>) {
        self._userKey = key
        
        if let username = dictionary["username"] as? String {
            self._username = username
        } else {
            self._username = "New User"
        }
        
        if let loginType = dictionary["provider"] as? String {
            self._loginType = loginType
        } else {
            self._loginType = "unknown"
        }
        if let profileImgUrl = dictionary["profileImgUrl"] as? String {
            self._profileImgUrl = profileImgUrl
        } else {
            self._profileImgUrl = ""
        }
        if let userEmail = dictionary["email"] as? String {
            self._userEmail = userEmail
        } else {
            self._userEmail = ""
        }
    }
    
    func updateProfileImg(imgUrl: String) {
        self._profileImgUrl = imgUrl
    }
    
    func updateEmail(email: String) {
        self._userEmail = email
        
    }
    
    func updateUsername(username: String) {
        self._username = username
    }
    
    func updateUserInDatabase() {
        
        DataService.ds.REF_USERS.child(_userKey).updateChildValues(["username": self._username!, "email": self._userEmail!, "profileImgUrl": self._profileImgUrl!])
        
    }
    
    
    
    func setProfileImage() -> UIImage {
        

        
        if self.profileImgUrl != "" {
            
            if let img = FeedVC.imageCache.objectForKey(self.profileImgUrl) as? UIImage {
                return img
                
            } else {
                if let data = NSData(contentsOfURL: NSURL(string: self.profileImgUrl)!) {
                    let img = UIImage(data: data)!
                    return img
                }
            }

        }
        
        return UIImage(named: "Genprofile")!
        
        
    }
    
    
}
