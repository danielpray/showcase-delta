//
//  UserSettingsVC.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/16/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class UserSettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var profilePicImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameTextField: MaterialTextField!
    @IBOutlet weak var emailTextField: MaterialTextField!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Current user: \(currentUser.username)")
        print(currentUser.loginType)
        print(currentUser.profileImgUrl)
        print(currentUser.userKey)
        
        usernameLbl.text = currentUser.username
        emailLabel.text = currentUser.userEmail
        
        profilePicImg.image = currentUser.setProfileImage()

        

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profilePicImg.image = image
        imageSelected = true
    }
    
    
    
    
    @IBAction func changeProfilePic(sender: AnyObject) {
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func updateUserData(sender: AnyObject) {
        
        if usernameTextField.text != "" {
            currentUser.updateUsername(usernameTextField.text!)
        }
        if emailTextField.text != "" {
            currentUser.updateEmail(emailTextField.text!)
        }
        
        if let img =  profilePicImg.image where imageSelected == true {
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
                print(encodingResult)
                switch encodingResult {
                case .Success(request: let upload, _, _):
                    upload.responseJSON(completionHandler: { (resp) in
                        // let response = resp.response
                        let result = resp.result
                        print(result)
                        // let request = resp.request
                        
                        if let info = result.value as? Dictionary<String,AnyObject> {
                            if let links = info["links"] as? Dictionary<String,AnyObject> {
                                if let imgLink = links["image_link"] as? String {
                                    // print("LINK: \(imgLink)")
                                    currentUser.updateProfileImg(imgLink)
                                    currentUser.updateUserInDatabase()
                                    self.usernameLbl.text = ""
                                    self.emailLabel.text = ""
                                    self.profilePicImg.image = UIImage(named: "Genprofile")
                                    self.dismissViewControllerAnimated(true, completion: nil)

                                    
                                }
                            }
                        }
                        
                        
                    })
                case .Failure(let error):
                    print(error)
                    

                    
                }
                
            }
        } else {
            currentUser.updateProfileImg("")
        }
    
        //currentUser.updateUserInDatabase()
    }
    
    


}


