//
//  PostVC.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/23/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PostVC: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var postDescription: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    
    var post: Post!
    var comments = [Comment]()
    var cellCount = 0
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_COMMENTS.observeEventType(.Value, withBlock: { snapshot in
            
            self.comments = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let commentDict = snap.value as? Dictionary<String,AnyObject> {
                        if let postKey = commentDict["postKey"] as? String {
                            if postKey == self.post.postKey {
                                self.cellCount = self.cellCount + 1
                                let commentKey = snap.key
                                let comment = Comment(key: commentKey, dictionary: commentDict)
                                self.comments.append(comment)
                            }
                            
                        }
                    }
                    
                }
                
                
            }
           self.tableView.reloadData()
        })
        
        
    
    }

    override func viewDidAppear(animated: Bool) {
        
        postImage.clipsToBounds = true
        profileImage.clipsToBounds = true
        
        if let pst = post {
            let txt = pst.postDescription
            postDescription.text = txt
            let usrname = pst.user?.username
            userLabel.text = usrname
            
            profileImage.image = post.user?.setProfileImage()
            
            if post.imageURL != nil {
                if let img = FeedVC.imageCache.objectForKey(post.imageURL!) as? UIImage {
                    postImage.image = img
                    postImage.hidden = false
                }
                
            } else {
                postImage.hidden = true
            }
        } else {
            postDescription.text = "Could not load post"
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: \(cellCount)")
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier(REUSE_CELL_COMMENT)! as? CommentCell {
            cell.request?.cancel()
            var img: UIImage?
            if let url = comment.user?.profileImgUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
                
            }
            cell.configureCell(comment, profImg: img)
            return cell
        }
        return CommentCell()
    }
    
    @IBAction func showCommentBox(sender: UIButton) {
        
        commentButton.hidden = true
        commentTextField.hidden = false
        postButton.hidden = false
        
    }
    
    @IBAction func postComment(sender: UIButton) {
        
        let postdesc = commentTextField.text
        if postdesc != "" {
            let firebaseComment = DataService.ds.REF_COMMENTS.childByAutoId()
            let postDict: Dictionary<String,AnyObject> = ["userKey": currentUser.userKey,
                        "postKey": post.postKey,
                        "description": postdesc!,
                        "likes": 0]
            firebaseComment.setValue(postDict)
            let postAddress = DataService.ds.REF_POSTS.child(post.postKey).child("comments")
            postAddress.setValue([firebaseComment.key: "true"])
            let userAddress = DataService.ds.REF_USERS.child(currentUser.userKey).child("comments")
            userAddress.setValue([firebaseComment.key: "true"])
            
            
        }
        commentButton.hidden = false
        commentTextField.hidden = true
        postButton.hidden = true
    }
    
    
}
