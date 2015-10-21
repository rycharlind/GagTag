//
//  SettingsViewController.swift
//  GagTag
//
//  Created by Ryan on 10/13/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func friends(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("friendsMenuNav") as! UINavigationController
        self.showViewController(vc, sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            self.navItem.title = PFUser.currentUser()?.username
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
