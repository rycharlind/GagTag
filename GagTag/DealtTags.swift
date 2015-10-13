//
//  DealtTagsViewController.swift
//  GagTag
//
//  Created by Ryan on 9/16/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol DealtTagsViewControllerDelegate {
    func dealtTagsViewController(controller: DealtTagsViewController, didSelectTag tag: PFObject)
}

class DealtTagsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK:  Properties
    var delegate: DealtTagsViewControllerDelegate?
    @IBOutlet weak var barButtonChoose: UIBarButtonItem!
    @IBOutlet weak var barButtonCancel: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var gag : PFObject!
    var tags : [PFObject]!
    var selectedTag : PFObject!
    
    
    // MARK:  Actions
    @IBAction func choose(sender: AnyObject) {
        
        self.sendChosenTag(self.selectedTag)
        /*
        if let delegate = self.delegate {
            delegate.dealtTagsViewController(self, didSelectTag: self.selectedTag)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        */
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tags = [PFObject]()
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.queryDealtTags()
        self.dealTags()
        print(self.gag)
    }
    
    func queryDealtTags() {
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.includeKey("dealtTags")
        
        
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                print("Successfully retrieved the object. \(object)")
                
                if let dealtTags = object?["dealtTags"] as? [PFObject] {
                    self.tags = dealtTags
                    self.tableView.reloadData()
                }
                print("My Tags: \(self.tags)")
            }
        })
        
    }
    
    func dealTags() {
        
        // Queries all the GagUserTag objects related to this gag
        // If the current user already has an object created then use those dealtTags
        // Else
        // Query new tags excluding all the current dealtTag to other users
        // Then 
        // Select 5 random tags
            // Iterate 5 times
            // Generate radndom index
            // Get Tag from all Tags
            // Remove tag from all Tags
            // Repeat
        
        let queryGagUserTag = PFQuery(className: "GagUserTag")
        queryGagUserTag.whereKey("gag", equalTo: self.gag)
        queryGagUserTag.includeKey("user")
        queryGagUserTag.includeKey("dealtTags")
        queryGagUserTag.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                
                if let objects = objects as? [PFObject] {
                    
                    var currentDealTagsObjectIds = [String]()
                    var dealtTags = [PFObject]()
                    
                    // Iterate through each GagUserTag and check if current user has dealtTags
                    var hasDealtTags = false
                    for object in objects {
                        let user = object["user"] as! PFUser
                        if (user.objectId == PFUser.currentUser()?.objectId) {
                            hasDealtTags = true
                            dealtTags = object["dealtTags"] as! [PFObject]
                        }
                    }
                    
                    
                    if (hasDealtTags == true) {
                        
                        print("User has dealt tags")
                        //println(dealtTags)
                        self.tags = dealtTags
                        self.tableView.reloadData()
                        
                    } else {
                        
                        // Concatenate all the dealt tags
                        for dealtTag in dealtTags {
                            currentDealTagsObjectIds.append(dealtTag.objectId!)
                        }
                        
                        // Query all tags not contained inside currentDealtTags
                        let query = PFQuery(className: "Tag")
                        query.whereKey("objectId", notContainedIn: currentDealTagsObjectIds)
                        query.limit = 1000
                        query.findObjectsInBackgroundWithBlock({
                            (objects: [AnyObject]?, error: NSError?) -> Void in
                            if (error == nil) {
                                
                                if var objects = objects as? [PFObject] {
                                    
                                    let numOfTags = 5
                                    for (var x = 0; x < numOfTags; x++) {
                                        let count = UInt32(objects.count)
                                        let index = Int(arc4random_uniform(count))
                                        self.tags.append(objects[index])
                                        objects.removeAtIndex(5)
                                    }
                                    
                                    print(self.tags)
                                    self.tableView.reloadData()
                                    
                                }
                                
                                // Create new GagUserTag with newly dealtTags
                                let gagUserTag = PFObject(className: "GagUserTag")
                                gagUserTag["user"] = PFUser.currentUser()!
                                gagUserTag["gag"] = self.gag
                                gagUserTag["dealtTags"] = self.tags
                                gagUserTag.saveInBackground()
                                
                            } else {
                                print("Error: \(error!) \(error!.userInfo)")
                            }
                            
                        })
                        
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        })
        
    }
    
    func sendChosenTag(tag : PFObject) {
        print("sendChosenTag")
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                object?.setObject(tag, forKey: "chosenTag")
                object?.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        // There was a problem, check error.description
                    }
                })
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
        return self.tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        let tag = self.tags[indexPath.row] as PFObject
        cell?.textLabel?.text = "#" + (tag["value"] as? String)!
        
        if (tag.objectId == self.selectedTag?.objectId) {
            cell?.accessoryType = .Checkmark
        } else {
            cell?.accessoryType = .None
        }
    
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let row = Int(indexPath.row)
        
        let currentObject = self.tags[row] as PFObject
        
        if let objId = currentObject.objectId {
            self.selectedTag = currentObject
            self.barButtonChoose.enabled = true
            self.tableView.reloadData()
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
