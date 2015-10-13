//
//  FriendRequestsViewController.swift
//  GagTag
//
//  Created by Ryan on 10/4/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var friendRequests = [PFObject]()
    
    
    // MARK: Actions
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "FriendRequestCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "friendRequestCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.queryFriendRequests()
    }
    
    func queryFriendRequests() {
        var query = PFQuery(className: "Friends")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.whereKey("approved", equalTo: false)
        query.whereKey("dismissed", equalTo: false)
        query.includeKey("friend")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if let objects = objects as? [PFObject] {
                    self.friendRequests = objects
                    print(self.friendRequests)
                    self.tableView.reloadData()
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendRequests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("friendRequestCell") as! FriendRequestCell!
        if cell == nil {
            cell = FriendRequestCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "friendRequestCell")
        }
        
        let friendRequest = self.friendRequests[indexPath.row] as PFObject
        cell?.friendRequest = friendRequest
        
        let friend = friendRequest["friend"] as! PFUser
        cell?.labelUsername?.text = friend["username"] as? String
        
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
