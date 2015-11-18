//
//  TagsTableViewController.swift
//  GagTag
//
//  Created by Ryan on 9/8/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol TagsViewControllerDelegate {
    func tagsViewController(controller: TagsViewController, didSelectTag tag: PFObject)
}

class TagsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var gag : PFObject!
    var gagUser : PFObject!
    var tags : [AnyObject]!
    var gagUserTags : [PFObject]!
    var selectedObjects : [String:PFObject]!
    var selectedTag : PFObject!
    var delegate: TagsViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func choose(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.tagsViewController(self, didSelectTag: self.selectedTag)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tags = [PFObject]()
        self.gagUserTags = [PFObject]()
        self.selectedObjects = [String:PFObject]()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (self.gag != nil) {
            if let user : PFObject = self.gag["user"] as? PFObject {
                self.gagUser = user
                if (self.gagUser.objectId == PFUser.currentUser()?.objectId) {
                    self.queryGagUserTags()
                } else {
                    self.queryDealtTags()
                }
            }
        }
    }
    
    func queryGagUserTags() {
        print("Query Gag User Tags")
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.includeKey("user")
        query.includeKey("dealtTags")
        query.includeKey("chosenTag")
        query.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                self.gagUserTags = objects
                self.tableView.reloadData()
            }
        })
    }
    
    func queryDealtTags() {
        print("Query Dealt Tags")
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
                //self.tags = object?["dealtTags"] as! [PFObject]
                
                if let dealtTags = object?["dealtTags"] as? [AnyObject] {
                    //println("Dealt Tags: \(dealtTags)")
                    self.tags = dealtTags
                    self.tableView.reloadData()
                }
                print("My Tags: \(self.tags)")
                
            }
        })
    }
    
    func queryChosenTags() {
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.includeKey("chosenTag")
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                for object in objects! {
                    print(object.objectId)
                    if let tag = object["chosenTag"] as? PFObject {
                        self.tags.append(tag)
                    }
                }
                self.tableView.reloadData()
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
        
        if (self.gagUser?.objectId == PFUser.currentUser()?.objectId) {
            return self.gagUserTags.count
        } else {
            if (self.tags?.count > 0) {
                return self.tags.count
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        // Current user's gag - View chosen tags or usernames
        if (self.gagUser?.objectId == PFUser.currentUser()?.objectId) {
            
            // Display username and status if NOT all chosenTags are available
            if (self.gagUserTags.count > 0) {
                if let gagUserTag = self.gagUserTags[indexPath.row] as? PFObject {
                    if let chosenTag = gagUserTag["chosenTag"] as? PFObject {
                        cell?.textLabel?.text = "#" + (chosenTag["value"] as? String)!
                    } else {
                        
                        if let user = gagUserTag["user"] as? PFObject {
                            cell?.textLabel?.text = user["username"] as? String
                        }
                    }
                }
            }
            
            
        // Other user's gag - View dealt tags
        } else {
        
            
            if (self.tags?.count > 0) {
                if let tag = self.tags[indexPath.row] as? PFObject {
                    cell?.textLabel?.text = tag["value"] as? String
                    
                    if (tag.objectId == self.selectedTag?.objectId) {
                        cell?.accessoryType = .Checkmark
                    } else {
                        cell?.accessoryType = .None
                    }
                }
            }

        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let row = Int(indexPath.row)
        
        if (self.gagUser?.objectId != PFUser.currentUser()?.objectId) {
            
            let currentObject = self.tags[row] as! PFObject
            
            if let objId = currentObject.objectId {
                self.selectedTag = currentObject
                self.tableView.reloadData()
            }
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
