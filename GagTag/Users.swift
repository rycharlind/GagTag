//
//  UsersTableViewController.swift
//  GagTag
//
//  Created by Ryan on 9/4/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse
import ParseUI


protocol UsersViewControllerDelegate {
    func usersTableViewController(controller: UsersViewController, didSelectUsers users: [String:PFObject])
}

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    var objects = [PFObject]()
    var selectedObjects = [String:PFObject]()
    var delegate: UsersViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    // MARK: Actions
    
    @IBAction func send(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.usersTableViewController(self, didSelectUsers: self.selectedObjects)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        queryUsers()
    }
    
    func queryUsers() {
        var query = PFQuery(className: "_User")
        query.whereKey("objectId", notEqualTo: PFUser.currentUser()!.objectId!)
        query.orderByAscending("username")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                self.objects = objects as! [PFObject]
                //println("Users: \(self.objects)")
                self.tableView.reloadData()
            } else {
                print("Error: \(error!) \(error!.userInfo)")
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
        return self.objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        if (self.objects.count > 0) {
            let user = self.objects[indexPath.row] as PFObject
            cell?.textLabel?.text = user["username"] as? String
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let row = Int(indexPath.row)
        
        
        let currentObject = self.objects[row] as PFObject
        
        if let objId = currentObject.objectId {
            
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
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
