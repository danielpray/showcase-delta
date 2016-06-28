//
//  ViewController.swift
//  showcase-delta
//
//  Created by Daniel Ray on 6/7/16.
//  Copyright © 2016 Daniel Ray. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth




class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
           
        }
    }

    
    @IBAction func fbButtonPressed(sender: UIButton!) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            
            if facebookError != nil {
               print("Facebook Login Failed. Error: \(facebookError)")
            } else {
               // let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with Facebook")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
                
               
                
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        
                       // print("Login Failed: \(error)")
                        
                    } else {
                       // print("Logged In")
                        
                        let userData = ["provider": credential.provider]
                        DataService.ds.createFirebaseUser((user!.uid), user: userData)
                        
                        //print(user!.uid)
                        
                        
                      
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                        
                        
                        
                       
                        
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                        
                   
                        
                    }
                })
                
            }
        }
        
    }

    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                
                if error != nil {
                   // print(error)
                    if error!.code == STATUS_ACCOUNT_NONEXIST {
                        FIRAuth.auth()?.createUserWithEmail(email, password: pwd, completion: { (user, error) in
                            if error != nil {
                                self.showMessageAlert("Could not create account", msg: "Problem creating account.  Try something else")
                            } else {
                                
                                NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                                
                                let userData = ["provider": "email", "email": email]
                                DataService.ds.createFirebaseUser(user!.uid, user: userData)
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                
                            }
                        })
                    } else {
                        self.showMessageAlert("Could not log in", msg: "Could not log in. Please check user name or password")
                    }
                } else {
                    
                    NSUserDefaults.standardUserDefaults().setValue(user!.uid, forKey: KEY_UID)
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    
                    
                }
                
            })
            
        } else {
            showMessageAlert("Email and Password Required", msg: "You must enter and email and password")
        }
        
    }
    
    func showMessageAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

