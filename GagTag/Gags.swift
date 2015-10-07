//
//  ViewController.swift
//  GagTag
//
//  Created by Ryan on 9/1/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

// Display gag that was sent by you and all friends have responded
// Display gag that was sent by you but NOT all friends have responded
// Display finsihed gag - Ones that have a winningTag

import UIKit
import Parse
import ParseUI

class GagsViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var gags : [PFObject]!
    @IBOutlet weak var tableView: UITableView!
    
    
    // Mark: Actions
    @IBAction func logout(sender: UIBarButtonItem) {
        PFUser.logOut()
        showParseLogin()
    }
    
    @IBAction func findFriends(sender: AnyObject) {
        //self.showFindFriends()
        self.showFriendsMenuNav()
    }
    
    @IBAction func feed(sender: AnyObject) {
        self.showMyGagFeed()
        //self.showDealtTags()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.gags = [PFObject]()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        var currentUser = PFUser.currentUser()
        if currentUser == nil {
            showParseLogin()
        } else {
            self.queryGags()
            self.navigationItem.title = PFUser.currentUser()?.username
        }
    }
    
    func showDealtTags() {
        var dealtTagsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("dealtTags") as! DealtTagsViewController
        //dealtTagsViewController.gag = gag
        self.presentViewController(dealtTagsViewController, animated: true, completion: nil)
    }
    
    func showMyGagFeed() {
        var gagFeedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gagFeed") as! GagFeedViewController
        self.presentViewController(gagFeedViewController, animated: true, completion: nil)
    }
    
    func showFriendsMenuNav() {
        var friendsMenuNavViewController = self.storyboard?.instantiateViewControllerWithIdentifier("friendsMenuNav") as! UINavigationController
        self.presentViewController(friendsMenuNavViewController, animated: true, completion: nil)
    }
    
    func showFindFriends() {
        var findFreindsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("findFriends") as! FindFriendsViewController
        self.presentViewController(findFreindsViewController, animated: true, completion: nil)
    }
    
    func showTags() {
        var loginController = self.storyboard?.instantiateViewControllerWithIdentifier("tags") as! UITableViewController
        self.presentViewController(loginController, animated: true, completion: nil)
    }
    
    func showGagReel() {
        var loginController = self.storyboard?.instantiateViewControllerWithIdentifier("reel") as! UITableViewController
        self.presentViewController(loginController, animated: true, completion: nil)
    }
    
    func showCustomLogin() {
        var loginController = self.storyboard?.instantiateViewControllerWithIdentifier("loginNav") as! UINavigationController
        self.presentViewController(loginController, animated: true, completion: nil)
    }
    
    func showParseLogin() {
        
        // Not sure why I cannot assign the same UILabel to two different UIView's
        let labelLoginGagTag = UILabel()
        labelLoginGagTag.text = "GagTag"
        labelLoginGagTag.font = UIFont(name: labelLoginGagTag.font.fontName, size: 40)
        
        let labelSignUpGagTag = UILabel()
        labelSignUpGagTag.text = "GagTag"
        labelSignUpGagTag.font = UIFont(name: labelSignUpGagTag.font.fontName, size: 40)
        
        var parseLoginViewController = PFLogInViewController()
        parseLoginViewController.delegate = self
        parseLoginViewController.logInView?.logo = labelLoginGagTag
        
        var parseSignUpViewController = PFSignUpViewController()
        parseSignUpViewController.delegate = self
        parseSignUpViewController.signUpView?.logo = labelSignUpGagTag
        
        parseLoginViewController.signUpController = parseSignUpViewController
        
        self.presentViewController(parseLoginViewController, animated: true, completion: nil)
    }
    
    // MARK: PFLogInViewControllerDelegate
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        
        if (!username.isEmpty || !password.isEmpty) {
            return true
        } else {
            return false
        }
    
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let userNotiicationTypes : UIUserNotificationType = (UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound)
        
        let settings : UIUserNotificationSettings = UIUserNotificationSettings(forTypes: userNotiicationTypes, categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func queryGags() {
        let predicate = NSPredicate(format: "user = %@ OR friends = %@", PFUser.currentUser()!, PFUser.currentUser()!)
        var query = PFQuery(className: "Gag", predicate: predicate)
        query.includeKey("user")
        query.includeKey("winningTag")
        query.addDescendingOrder("updatedAt")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if let objects = objects as? [PFObject] {
                    self.gags = objects
                    //println(self.gags)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.gags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        }
        
        cell?.imageView?.image = UIImage(named: "glyphicons-274-drink")
        
        if let object = self.gags[indexPath.row] as? PFObject {
            
            
            // textLabel
            if let user = object["user"] as? PFObject {
                // Check if current user sent the gag
                if (user.objectId == PFUser.currentUser()?.objectId) {
                   cell?.textLabel?.text = "I sent this"
                } else {
                    cell?.textLabel?.text = user["username"] as? String
                }
            }
            
            // detailTextLabel
            // Check to see if a winning tag has been submitted
            if let winningTag = object["winningTag"] as? PFObject {
                cell?.detailTextLabel?.text = "#" + (winningTag["value"] as? String)!
                cell?.backgroundColor = UIColor(red: CGFloat(204) / 255, green: CGFloat(229) / 255, blue: CGFloat(255) / 255, alpha: 1)
            } else {
                
                var queryGagUserTags = PFQuery(className: "GagUserTag")
                queryGagUserTags.whereKey("gag", equalTo: object)
                queryGagUserTags.includeKey("chosenTag")
                queryGagUserTags.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    if (error == nil) {
                        //println("GagUserTags: \(objects)")
                        
                        // Check all GagUserTag's to see if they have a chosenTag
                        if let objects = objects as? [PFObject] {
                            
                            // Get chosenTag count
                            var tagCount = 0
                            for object in objects {
                                if let chosenTag = object["chosenTag"] as? PFObject {
                                    tagCount++
                                }
                            }
                            
                            // Compare tagCount against total number of GagUserTag objects
                            if (tagCount == objects.count) {
                                cell?.detailTextLabel?.text = "Ready"
                                cell?.backgroundColor = UIColor(red: CGFloat(204) / 255, green: CGFloat(255) / 255, blue: CGFloat(204) / 255, alpha: 1)
                            } else {
                                
                                if let user = object["user"] as? PFObject {
                                    // GagUser is current user
                                    if (user.objectId == PFUser.currentUser()?.objectId) {
                                        cell?.detailTextLabel?.text = "Not Ready"
                                        cell?.backgroundColor = UIColor(red: CGFloat(255) / 255, green: CGFloat(204) / 255, blue: CGFloat(204) / 255, alpha: 1)
                                    } else { // GagUser is NOT current user
                                        
                                        
                                        // Check if the current use has chosen a tag
                                        var currentUserChoseTag = false
                                        for object in objects {
                                            if let chosenTag = object["chosenTag"] as? PFObject {
                                                if let user = object["user"] as? PFObject {
                                                    if (user.objectId == PFUser.currentUser()?.objectId) {
                                                        currentUserChoseTag = true
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if (currentUserChoseTag == true) {
                                            cell?.detailTextLabel?.text = "Not Ready"
                                            cell?.backgroundColor = UIColor(red: CGFloat(255) / 255, green: CGFloat(204) / 255, blue: CGFloat(204) / 255, alpha: 1)
                                        } else {
                                            cell?.detailTextLabel?.text = "Ready"
                                            cell?.backgroundColor = UIColor(red: CGFloat(204) / 255, green: CGFloat(255) / 255, blue: CGFloat(204) / 255, alpha: 1)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        println("Error: \(error!) \(error!.userInfo!)")
                    }
                })
                
            }
            
        }
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let row = Int(indexPath.row)
        
        if let gag = self.gags[row] as? PFObject {
            let gagViewController : GagViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("gag") as! GagViewController
            gagViewController.gag = gag
            self.showViewController(gagViewController as GagViewController, sender: self)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




}

