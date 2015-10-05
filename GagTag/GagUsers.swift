//
//  GagUsersTableViewController.swift
//  GagTag
//
//  Created by Ryan on 9/18/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class GagUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var gag : PFObject!
    var gagUsers : [PFObject]!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.gagUsers = [PFObject]()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.queryGagUsers()    
    }
    
    func queryGagUsers() {
        var query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if let objects = objects as? [PFObject] {
                    self.gagUsers = objects
                    self.tableView.reloadData()
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
        return self.gagUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        
        
        
        if let gagUser = self.gagUsers[indexPath.row] as? PFObject {
            if let user = gagUser["user"] as? PFObject {
                cell?.textLabel?.text = user["username"] as? String
            }
        }
    
        
        
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
