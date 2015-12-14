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
        print(self.gag)
        ParseHelper.getAllGagUserTagObjectsForGag(self.gag, completionBlock: {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                self.gagUsers = objects
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
        return self.gagUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        }
        
        let gagUser = self.gagUsers[indexPath.row] as PFObject
        let user = gagUser["user"] as? PFObject
        let chosenTag = gagUser["chosenTag"] as? PFObject
        
        cell?.textLabel?.text = user?["username"] as? String
        if let tag = chosenTag {
            cell?.detailTextLabel?.text = "#" + (tag["value"] as? String)!
        }
        
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
