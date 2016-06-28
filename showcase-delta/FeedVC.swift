//
//  FeedVC.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/13/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Alamofire


var currentUser: User!
var users = [User]()

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var imageSelectorImg: UIImageView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var tableView: UITableView!
    var posts = [Post]()
    var imageSelected = false
    var currentUserKey: String!
    var currentUserFound = false

    
    var imagePicker: UIImagePickerController!
    static var imageCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print(NSUserDefaults.valueForKey(KEY_UID))
        
        currentUserKey = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        print("Current user key: \(currentUserKey)")
        //print("User Defaults: \(NSUserDefaults.standardUserDefaults().dictionaryRepresentation())")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 358
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_USERS.observeEventType(.Value, withBlock: { userSnapshot in
            
            
            if let userSnapshots = userSnapshot.children.allObjects as? [FIRDataSnapshot] {
                users = []
                
                for userSnap in userSnapshots {
                    print("Snap Key: \(userSnap.key)")
                    
                    if let userDict = userSnap.value as? Dictionary<String,AnyObject> {
                        let key = userSnap.key
                        //currentUser = User(key: key, dictionary: userDict)
                        //print("Dict: \(userDict)")
                        let usr = User(key: key, dictionary: userDict)
                        users.append(usr)
                        
                        if userSnap.key == self.currentUserKey {
                            currentUser = usr
                            self.currentUserFound = true
                        }
                        
                        
                    }
                   
                    
                }
                
                self.tableView.reloadData()
                
                if !self.currentUserFound {
                    currentUser = User(userKey: self.currentUserKey, loginType: "email")
                }
                
                
            }
            
            
        })
        
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock:{ snapshot in

            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    // print(snap)
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(key: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
                
            }
            
            
            
            
            
            self.tableView.reloadData()
    })
}
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        // print(post.postDescription)
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            var profImg: UIImage?
            if let url = post.imageURL {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            if let profUrl = post.user?.profileImgUrl {
                profImg = FeedVC.imageCache.objectForKey(profUrl) as? UIImage
                
            } else {
                profImg = nil
            }
            
            
            cell.configureCell(post, img: img, profImg: profImg)
            return cell
        }
        return PostCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageURL == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = posts[indexPath.row]
        performSegueWithIdentifier(SEGUE_POST_VC, sender: post)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImg.image = image
        imageSelected = true
    }
    
    @IBAction func selectAnImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func makePost(sender: MaterialButton) {
        
        if let txt = postField.text where txt != "" {
            
            if let img = imageSelectorImg.image where imageSelected == true {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { (multipartFormData) in
                    
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                
                }) { encodingResult in
                    switch encodingResult {
                    case .Success(request: let upload, _, _):
                        upload.responseJSON(completionHandler: { (resp) in
                            // let response = resp.response
                            let result = resp.result
                            // let request = resp.request
                            
                            if let info = result.value as? Dictionary<String,AnyObject> {
                                if let links = info["links"] as? Dictionary<String,AnyObject> {
                                    if let imgLink = links["image_link"] as? String {
                                       // print("LINK: \(imgLink)")
                                        self.postToFirebase(imgLink)
                                        
                                    }
                                }
                            }
                            
                            
                        })
                    case .Failure(let error):
                        print(error)
                    
                    
                    }
                    
                }
            } else {
                self.postToFirebase(nil)
            }
            
        }
        
    }
    
    func postToFirebase(imageUrl: String?) {
        
        var post: Dictionary<String,AnyObject> = [
        "description": postField.text!,
        "likes": 0,
        "userKey": currentUser.userKey]
        
        if imageUrl != nil {
            post["imageURL"] = imageUrl!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        postField.text = ""
        imageSelectorImg.image = UIImage(named: "camera")
        imageSelected = false
        DataService.ds.REF_USERS.child("posts").setValue(firebasePost.key) //new
        tableView.reloadData()
        
        
    }
    
  
    @IBAction func showSettings(sender: AnyObject) {
        
        self.performSegueWithIdentifier(SEGUE_SETTINGS, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_POST_VC {
            
            if let pst = sender as? Post {
                if let postVC = segue.destinationViewController as? PostVC {
                    postVC.post = pst
                }
            }
            
        }
    }
}
