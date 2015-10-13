//
//  FriendsViewController.swift
//  GagTag
//
//  Created by Ryan on 9/20/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class FindFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //var friends : [PFObject]!
    var users : [User]!
    var friendRequests : [User]!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.friends = [PFObject]()
        self.users = [User]()
        self.friendRequests = [User]()
        
        let nib = UINib(nibName: "FindFriendsCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "findFriendsCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.queryUsers()
    }
    
    func queryUsers() {
        
        // Query all the current users friends
        var queryFriends = PFQuery(className: "Friends")
        queryFriends.whereKey("user", equalTo: PFUser.currentUser()!)
        queryFriends.includeKey("friend")
        queryFriends.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {

                // Create an array of the friends objectIds
                var friendsObjectIds = [String]()
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        var friend = object["friend"] as! PFObject
                        friendsObjectIds.append(friend.objectId!)
                    }
                }
                
                
                // Query all users
                var query = PFQuery(className: "_User")
                query.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
                query.orderByAscending("username")
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    if (error == nil) {
                        
                        
                        // Iterate through each user and check if they are a friend
                        if let objects = objects as? [PFUser] {
                            for pfuser in objects {
                                var user = User()
                                
                                user.username = pfuser["username"] as! String
                                user.pfuser = pfuser
                                
                                if friendsObjectIds.contains((pfuser.objectId!)) {
                                    user.isFriend = true
                                }
                                
                                self.users.append(user)
                            }
                        }

                        
                        //println("New Users: \(self.users)")
                        
                        self.tableView.reloadData()
                    
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                })
                
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
            
        })

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("findFriendsCell") as! FindFriendsCell!
        if cell == nil {
            cell = FindFriendsCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "findFriendscell")
        }
        
        
        let user = self.users[indexPath.row] as User
        cell?.labelUsername.text = user.username
        cell?.friend = user.pfuser
        if (user.isFriend == true) {
            cell?.buttonAction.setTitle("Remove", forState: UIControlState.Normal)
            
        }
            
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
