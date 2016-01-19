//
//  DealtTagsViewController.swift
//  GagTag
//
//  Created by Ryan on 9/16/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol TagsViewControllerDelegate {
    func dealtTagsViewController(controller: TagsViewController, didSelectTag tag: PFObject)
}

public enum TagsType {
    case DealtTags
    case ChosenTags
}

public enum TagCondition {
    case New
    case Dealt
}

class TagsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK:  Properties
    var delegate: TagsViewControllerDelegate?
    @IBOutlet weak var barButtonChoose: UIBarButtonItem!
    @IBOutlet weak var barButtonCancel: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var gag : PFObject!
    var tags : [PFObject]!
    var selectedTag : PFObject!
    var newTag: PFObject!
    var type: TagsType = .DealtTags
    var tagCondition: TagCondition = .Dealt
    
    // MARK:  Actions
    @IBAction func choose(sender: AnyObject) {
        
        self.barButtonChoose.enabled = false
        switch type {
        case .DealtTags:
            
            
            switch tagCondition {
            case .New:
                
                // New Tag
                let query = PFQuery(className: "Tag")
                query.whereKey("value", matchesRegex: self.getNewTagValue(), modifiers: "i")
                //query.whereKey("value", equalTo: self.getNewTagValue())
                //let query = PFUser.query()!.whereKey("username", matchesRegex: searchText, modifiers: "i")
                query.countObjectsInBackgroundWithBlock({
                    (count: Int32, error: NSError?) -> Void in
                    print(count)
                    if (count == 0) {
                        
                        // Save New Tag
                        let newTag = PFObject(className: "Tag")
                        newTag["value"] = self.getNewTagValue()
                        newTag["user"] = PFUser.currentUser()!
                        newTag.saveInBackgroundWithBlock({
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                // Fetch newly created Tag
                                newTag.fetchIfNeededInBackgroundWithBlock({
                                    (object: PFObject?, error: NSError?) -> Void in
                                    if let object = object {
                                        
                                        // Send newly created chosen tag
                                        ParseHelper.sendChosenDealtTagForGag(self.gag, tag: object, completionBlock: {
                                            (success: Bool, error: NSError?) -> Void in
                                            if (success) {
                                                self.dismissViewControllerAnimated(true, completion: nil)
                                            } else {
                                                print(error)
                                            }
                                        })
                                        
                                    }
                                })
                            }
                        })
                        
                    } else {
                        print("Tag is already created")
                        let alert = UIAlertController(title: "Tags Taken", message: "Try again", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                
                
            case .Dealt:
                print("dealt")
                
                ParseHelper.sendChosenDealtTagForGag(gag, tag: selectedTag, completionBlock: {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        print(error)
                    }
                })
                
                
            }
            
        
        
        case .ChosenTags:
            ParseHelper.sendWinningTagForGag(gag, tag: selectedTag, completionBlock: {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    print(error)
                }
            })
        }
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tags = [PFObject]()
        self.newTag = PFObject(className: "Tag")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        barButtonChoose.enabled = false
        
        
        switch type {
        case .DealtTags:
            print("Dealt Tags")
            ParseHelper.getMyTagsForGag(self.gag, completionBlock: {
                (tags: [PFObject]?) -> Void in
                self.tags = tags
                self.tableView.reloadData()
            })
        case .ChosenTags:
            print("Chosen Tags")
            let allowedNumberOfTags = self.gag["allowedNumberOfTags"] as! Int
            ParseHelper.getChosenTagsForGag(gag, limit: allowedNumberOfTags, completionBlock: {
                (tags: [PFObject]?) -> Void in
                if (tags != nil) {
                    self.tags = tags
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (type == .ChosenTags) {
            return 1
        }
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (type == .ChosenTags) {
            return self.tags.count
        } else {
            if (section == 0) {
                return 1
            }
            return self.tags.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (type == .ChosenTags) {
            return "Choose a winning tag"
        } else {
            if (section == 0) {
                return "Add new"
            }
            return "Dealt tags"
        }
    
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (type == .DealtTags) {
            if (indexPath.section == 0) {
                let cell = tableView.dequeueReusableCellWithIdentifier("addTagCell") as! AddTagCell!
                cell.gag = self.gag
                cell.rippleLayerColor = UIColor.MKColor.LightGreen
                return cell
                
            }
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier("tagsCell") as! TagsCell!
        if cell == nil {
            cell = TagsCell(style: UITableViewCellStyle.Default, reuseIdentifier: "tagsCell")
        }
        
        let tag = self.tags[indexPath.row] as PFObject
        let value = tag["value"] as! String
        cell?.labelTag?.text = " #\(value)"
        
        
        if (tag.objectId == self.selectedTag?.objectId) {
            cell.tagSelected = true
        } else {
            cell.tagSelected = false
        }
        
        cell.rippleLayerColor = UIColor.MKColor.LightBlue
        
        return cell

        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (type == .DealtTags) {
            
            let ip = NSIndexPath(forRow: 0, inSection: 0)
            let addTagCell = tableView.cellForRowAtIndexPath(ip) as! AddTagCell
            
            if (indexPath.section == 0) {
                
                self.handleRefreshForCell(addTagCell)
                addTagCell.textField.becomeFirstResponder()
                
            } else {
                
                let tagCell = tableView.cellForRowAtIndexPath(indexPath) as! TagsCell
                addTagCell.tagSelected = false
                addTagCell.textField.resignFirstResponder()
                tagCondition = .Dealt
                
                let row = Int(indexPath.row)
                let currentObject = self.tags[row] as PFObject
                if let _ = currentObject.objectId {
                    tagCell.tagSelected = true
                    selectedTag = currentObject
                    barButtonChoose.enabled = true
                    self.reloadTags(indexPath)
                }
            }
            
        } else {
            
            let tagCell = tableView.cellForRowAtIndexPath(indexPath) as! TagsCell
            let row = Int(indexPath.row)
            let currentObject = self.tags[row] as PFObject
            if let _ = currentObject.objectId {
                tagCell.tagSelected = true
                selectedTag = currentObject
                barButtonChoose.enabled = true
                self.reloadTags(indexPath)
            }
            
        }
        
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        print("TextField did begin editing method called")
        let ip = NSIndexPath(forRow: 0, inSection: 0)
        let addTagCell = tableView.cellForRowAtIndexPath(ip) as! AddTagCell
        self.handleRefreshForCell(addTagCell)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("TextField did end editing method called")
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("TextField should begin editing method called")
        return true;
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        print("TextField should clear method called")
        return true;
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("TextField should end editing method called")
        return true;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Only allow alpha characters
        for chr in (string.characters) {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }
    
    // MARK: Local functions
    func getNewTagValue() -> String {
        let ip = NSIndexPath(forRow: 0, inSection: 0)
        let addTagCell = tableView.cellForRowAtIndexPath(ip) as! AddTagCell
        return addTagCell.textField.text!
    }
    
    
    
    func reloadTags(skipIndexPath: NSIndexPath) {
        for (var i = 0; i < self.tags.count; i++) {
            if (i != skipIndexPath.row) {
                let ip = NSIndexPath(forRow: i, inSection: skipIndexPath.section)
                self.tableView.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }
    
    func handleRefreshForCell(cell: AddTagCell) {
        cell.tagSelected = true
        self.barButtonChoose.enabled = true
        self.tagCondition = .New
        self.selectedTag = self.newTag
        
        let ip = NSIndexPath(forRow: -1, inSection: 1)
        self.reloadTags(ip)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
