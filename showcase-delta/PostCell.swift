//
//  PostCell.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/13/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    
    var post: Post!
    var request: Request?
    var profRequest: Request?
    var likeRef: FIRDatabaseReference!
    var postUser: User!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
        //let tapComment = UITapGestureRecognizer(target: self, action: "commentTapped")
        //tapComment.numberOfTapsRequired = 1
        //descriptionText.addGestureRecognizer(tapComment)
        //descriptionText.userInteractionEnabled = true
        
        
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
            profileImage.clipsToBounds = true
        
            showcaseImage.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(post: Post, img: UIImage?, profImg: UIImage?) {
        
        
        
        self.post = post
        
        
        username.text = post.user!.username
        
       
        
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.user?.profileImgUrl != "" && post.user?.profileImgUrl != nil {
            if profImg != nil {
                profileImage.image = profImg
            } else {
                profRequest = Alamofire.request(.GET, (post.user?.profileImgUrl)!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, err) in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.profileImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: (self.post.user?.profileImgUrl)!)
                    }
                })
            }
        } else {
            profileImage.image = UIImage(named: "profile")
        }
        
        if post.imageURL != nil {
            if img != nil {
                self.showcaseImage.image = img
            } else {
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, err) in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageURL!)
                    }
                })
            }
            
        } else {
            self.showcaseImage.hidden = true
        }
        
        
        likeRef.observeSingleEventOfType(.Value, withBlock:  { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                //This means we have not liked this specific post
                self.likeImg.image = UIImage(named: "heart-empty")
                
            } else {
                self.likeImg.image = UIImage(named: "heart-full")
            }
            
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock:  { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                //This means we have not liked this specific post
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
                
            } else {
                self.likeImg.image = UIImage(named: "heart-full")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
            
        })

        
        
    }
    
    

    


}
