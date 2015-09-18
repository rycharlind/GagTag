//
//  ChosenTagsViewController.swift
//  GagTag
//
//  Created by Ryan on 9/16/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol ChosenTagsViewControllerDelegate {
    func chosenTagsViewController(controller: ChosenTagsViewController, didSelectTag tag: PFObject)
}

class ChosenTagsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK:  Properties
    @IBOutlet weak var barButtonChoose: UIBarButtonItem!
    @IBOutlet weak var barButtonCancel: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var delegate: ChosenTagsViewControllerDelegate?
    var gag : PFObject!
    var gagUserTags : [PFObject]!
    var selectedTag : PFObject!
    var allTagsChosen : Bool!
    
    // MARK:  Actions
    @IBAction func choose(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.chosenTagsViewController(self, didSelectTag: self.selectedTag)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.gagUserTags = [PFObject]()
        self.allTagsChosen = false
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateUI()
        queryGagUserTags()
    }
    
    func updateUI() {
        self.barButtonChoose.enabled = false
        if (self.allTagsChosen == true) {
            self.barButtonChoose.enabled = true
        }
        self.tableView.reloadData()
    }
    
    // MARK:  Query data
    func queryGagUserTags() {
        var query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.includeKey("user")
        query.includeKey("dealtTags")
        query.includeKey("chosenTag")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if let objects = objects as? [PFObject] {
                    
                    // Set gagUserTags object
                    self.gagUserTags = objects
                    
                    // Get chosenTag count
                    var tagCount = 0
                    for object in objects {
                        if let chosenTag = object["chosenTag"] as? PFObject {
                            tagCount++
                        }
                    }
                    
                    // Compare tagCount against total number of GagUserTag objects
                    if (tagCount == objects.count) {
                        self.allTagsChosen = true
                    } else {
                        self.allTagsChosen = false
                    }
                    
                    // UpdateUI
                    self.updateUI()
                    
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
        return self.gagUserTags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        }
        
        if (self.gagUserTags.count > 0) {
            if let gagUserTag = self.gagUserTags[indexPath.row] as? PFObject {
                
                if (self.allTagsChosen == true) {
                    
                    if let chosenTag = gagUserTag["chosenTag"] as? PFObject {
                        
                        cell?.textLabel?.text = "#" + (chosenTag["value"] as? String)!
                        
                        // Check the chosen Tag
                        if (chosenTag.objectId == self.selectedTag?.objectId) {
                            cell?.accessoryType = .Checkmark
                        } else {
                            cell?.accessoryType = .None
                        }
                        
                    }
                    
                } else {
                    
                    if let user = gagUserTag["user"] as? PFObject {
                        cell?.textLabel?.text = user["username"] as? String
                        if let chosenTag = gagUserTag["chosenTag"] as? PFObject {
                            cell?.detailTextLabel?.text = "Ready"
                        } else {
                            cell?.detailTextLabel?.text = "Not Ready"
                        }
                    }
                }
            }
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let row = Int(indexPath.row)
        
        let gagUserTag = self.gagUserTags[row] as PFObject
        
        if let chosenTag = gagUserTag["chosenTag"] as? PFObject {
            
            self.selectedTag = chosenTag
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
