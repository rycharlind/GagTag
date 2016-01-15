//
//  SettingsViewController.swift
//  GagTag
//
//  Created by Ryan on 10/13/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UITableViewController {
    
    // MARK: Properties
    var titleLabel: UILabel!
    
    // MARK: Actions
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleLabel = UILabel(frame: CGRectMake(0,0,100,32))
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            titleLabel.text = PFUser.currentUser()?.username
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        switch (indexPath.row) {
        case 0: // Friends
            cell.textLabel!.text = "Friends"
            cell.backgroundColor = UIColor.MKColor.Blue
            cell.imageView?.image = UIImage(named: "glyphicons-44-group")
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        case 1: // Email
            cell.textLabel!.text = PFUser.currentUser()!.email
            cell.backgroundColor = UIColor.MKColor.Indigo
            cell.imageView?.image = UIImage(named: "glyphicons-11-envelope")
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        case 2: // Password
            cell.textLabel!.text = "Password"
            cell.backgroundColor = UIColor.MKColor.Cyan
            cell.imageView?.image = UIImage(named: "glyphicons-204-lock")
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        case 3: // Logout
            cell.textLabel!.text = "Sign Out"
            cell.backgroundColor = UIColor.MKColor.Amber
            cell.imageView?.image = UIImage(named: "glyphicons-388-log-out")
        default:
            print("")
        }
        
        return cell
    
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.row) {
        case 0:
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("friendsMenu") as! UITableViewController
            self.navigationController?.showViewController(vc, sender: self)
        case 3:
            PFUser.logOut()
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            print("Default")
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
