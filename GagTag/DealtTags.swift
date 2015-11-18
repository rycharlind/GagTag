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
    
    enum State {
        case TagChosen
        case TagNotChosen
    }
    
    var state: State = .TagChosen {
        didSet {
            switch state {
            case .TagChosen:
                print("State: TagChosen")
                barButtonChoose.enabled = false
            case .TagNotChosen:
                print("State: TagNotChosen")
                barButtonChoose.enabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tags = [PFObject]()
    }
    
    override func viewDidAppear(animated: Bool) {
        print(self.gag)
        ParseHelper.getMyTagsForGag(self.gag, completionBlock: {
            (tags: [PFObject]?) -> Void in
            self.tags = tags
            print(self.tags)
            self.tableView.reloadData()
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
