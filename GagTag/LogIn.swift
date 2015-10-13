//
//  Login.swift
//  GagTag
//
//  Created by Ryan on 9/4/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import Foundation

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextfField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: UIButton) {
        let username = usernameTextfField.text
        let password = passwordTextField.text
        
        PFUser.logInWithUsernameInBackground(username!, password:password!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Do stuff after successful login.
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                
                // The login failed. Check error to see why.
                let errorString = error!.userInfo["error"] as? NSString
                let alert = UIAlertView(title: "Error", message: String(errorString!), delegate: self, cancelButtonTitle: "Ok")
                alert.show()
                
            }
        }
        
        
    }
    
    
}
