//
//  GagFeedViewController.swift
//  GagTag
//
//  Created by Ryan on 10/5/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class GagFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    var gags : [PFObject]!
    var gagUserTag : PFObject!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.gags = [PFObject]()
        var nib = UINib(nibName: "GagFeedCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "gagFeedCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.queryGags()
    }
    
    func queryGags() {
        
        // Query all the current users friends
        var queryFriends = PFQuery(className: "Friends")
        queryFriends.whereKey("user", equalTo: PFUser.currentUser()!)
        queryFriends.whereKey("approved", equalTo: true)
        queryFriends.includeKey("friend")
        queryFriends.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                
                // Create an array of the friends
                var friends = [PFUser]()
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        var friend = object["friend"] as! PFUser
                        friends.append(friend)
                    }
                }
                
                // Query my friends Gags
                var query = PFQuery(className: "Gag")
                query.whereKey("user", containedIn: friends)
                query.includeKey("winningTag")
                query.orderByDescending("createdAt")
                query.findObjectsInBackgroundWithBlock({
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    if (error == nil) {
                        if let objects = objects as? [PFObject] {
                            self.gags = objects
                            self.tableView.reloadData()
                        }
                    } else {
                        println("Error: \(error!) \(error!.userInfo!)")
                    }
                })
            } else {
                println("Error: \(error!) \(error!.userInfo!)")
            }
            
        })
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gags.count
        //return 3
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 320
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("gagFeedCell") as! GagFeedCell!
        if cell == nil {
            cell = GagFeedCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "gagFeedCell")
        }
        
        
        let gag = self.gags[indexPath.row] as PFObject
        var pfimage = gag["image"] as! PFFile
        
        // Query Gag image
        pfimage.getDataInBackgroundWithBlock({
            (result, error) in
            if (error == nil) {
                println("got image")
                cell?.gagImageView.image = UIImage(data: result!)
            } else {
                println("Error: \(error!) \(error!.userInfo!)")
            }
        })
        
        
        // Query GagUserTag for chosenTag
        var query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: gag)
        query.includeKey("user")
        query.includeKey("chosenTag")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if let objects = objects as? [PFObject] {
                    let tagCount = objects.count
                    for object in objects {
                        let user = object["user"] as! PFUser
                        if (user.objectId == PFUser.currentUser()?.objectId) {
                            if let chosenTag = object["chosenTag"] as? PFObject {
                                cell?.labelTag?.text = "#" + (chosenTag["value"] as? String)!
                            } else {
                                cell?.labelTag?.text = "Not Tagged"
                            }
                        }
                    }
                }
            } else {
                println("Error: \(error!) \(error!.userInfo!)")
            }
        })
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Not sure why I have to use dispatch.  Explained in below StackOverflow
        // http://stackoverflow.com/questions/26165700/uitableviewcell-selection-storyboard-segue-is-slow-double-tapping-works-though
        
        
        dispatch_async(dispatch_get_main_queue(), {
            let gag = self.gags[indexPath.row] as PFObject
            var dealtTagsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("dealtTags") as! DealtTagsViewController
            dealtTagsViewController.gag = gag
            self.presentViewController(dealtTagsViewController, animated: true, completion: nil)
        });
        

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
