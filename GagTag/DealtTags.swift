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
        if let delegate = self.delegate {
            delegate.dealtTagsViewController(self, didSelectTag: self.selectedTag)
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
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.queryDealtTags()
        self.dealTags()
        println("view did appear")
    }
    
    func queryDealtTags() {
        var query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.includeKey("dealtTags")
        
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                println("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                println("Successfully retrieved the object. \(object)")
                
                if let dealtTags = object?["dealtTags"] as? [PFObject] {
                    self.tags = dealtTags
                    self.tableView.reloadData()
                }
                
                println("My Tags: \(self.tags)")
                
            }
        })
        
    }
    
    func dealTags() {
        println("dealTags")
        var query = PFQuery(className: "Tag")
        query.countObjectsInBackgroundWithBlock({
            (c: Int32, error: NSError?) -> Void in
            if error == nil {
                //let randomNumber = arc4random_uniform(count)
                var count = UInt32(c)
                let randomNumber = Int(arc4random_uniform(count))
                var randomNumberCast = Int(randomNumber)
                println(randomNumberCast)
                
                
                
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
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
            
        if (self.tags?.count > 0) {
            if let tag = self.tags[indexPath.row] as? PFObject {
                cell?.textLabel?.text = "#" + (tag["value"] as? String)!
                
                if (tag.objectId == self.selectedTag?.objectId) {
                    cell?.accessoryType = .Checkmark
                } else {
                    cell?.accessoryType = .None
                }
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
