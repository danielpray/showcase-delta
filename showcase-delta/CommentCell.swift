//
//  CommentCell.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/24/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire


class CommentCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var commentDescriptionTextView: UITextView!
    @IBOutlet weak var likeLabel: UILabel!
    
    var comment: Comment!
    var likeRef: FIRDatabaseReference!
    var commentUser: User!
    var request: Request!
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(comment: Comment, profImg: UIImage?) {
        
        self.comment = comment
        
        userNameLabel.text = comment.user?.username
        commentDescriptionTextView.text = comment.postDescription
        likeLabel.text = "\(comment.likes)"
        likeRef = DataService.ds.REF_USER_CURRENT.child("commentLikes").child(comment.commentKey)
        if comment.user?.profileImgUrl != nil && comment.user?.profileImgUrl != "" {
            if profImg != nil {
                profileImage.image = profImg
            } else {
                request = Alamofire.request(.GET, (comment.user?.profileImgUrl)!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, err) in
                    let img = UIImage(data: data!)!
                    self.profileImage.image = img
                })
            }
        }
        else {
            profileImage.image = UIImage(named: "profile")
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock:  { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.comment.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
                self.comment.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }

}
