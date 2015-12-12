//
//  ChosenTagsViewController.swift
//  GagTag
//
//  Created by Ryan on 11/23/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class ChosenTagsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barButtonChoose: UIBarButtonItem!
    @IBOutlet weak var barButtonCancel: UIBarButtonItem!
    var gag : PFObject!
    var tags : [PFObject]!
    var selectedTag : PFObject!
    
    // MARK:  Actions
    @IBAction func choose(sender: AnyObject) {
        ParseHelper.sendWinningTagForGag(gag, tag: selectedTag, completionBlock: {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("Success")
            }
        })
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var state: State = .TagChosen {
        didSet {
            switch state {
            case .TagChosen:
                barButtonChoose.enabled = false
            case .TagNotChosen:
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
        ParseHelper.getChosenTagsForGag(gag, completionBlock: {
            (tags: [PFObject]?) -> Void in
            if (tags != nil) {
                print(tags)
                self.tags = tags
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
    
    

}
