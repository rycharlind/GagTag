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
    var tags : [PFObject]!
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
        self.selectedObjects = [String:PFObject]()
    }
    
    override func viewDidAppear(animated: Bool) {
        queryTags()
    }
    
    func queryTags() {
        var query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.includeKey("dealtTags")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        println(object.objectId)
                        self.tags = object["dealtTags"] as? [PFObject]
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
        return self.tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        if (self.tags.count > 0) {
            let tag = self.tags[indexPath.row] as PFObject
            cell?.textLabel?.text = tag["value"] as? String
            
            if (tag.objectId == self.selectedTag?.objectId) {
                cell?.accessoryType = .Checkmark
            } else {
                cell?.accessoryType = .None
            }
            
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let row = Int(indexPath.row)
        
        let currentObject = self.tags[row] as PFObject
        
        if let objId = currentObject.objectId {
            
            self.selectedTag = currentObject
            self.tableView.reloadData()
            
            /*
            var isSelected = false
            for (key, value) in self.selectedObjects {
                if (key == currentObject.objectId) {
                    isSelected = true
                }
            }
            
            if (isSelected) {
                self.selectedObjects.removeValueForKey(currentObject.objectId!)
                cell?.accessoryType = .None
            } else {
                self.selectedObjects[objId] = currentObject
                cell?.accessoryType = .Checkmark
            }
            
            println(self.selectedObjects)
            */
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
