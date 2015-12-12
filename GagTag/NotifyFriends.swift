//
//  NotifyFriendsViewController.swift
//  GagTag
//
//  Created by Ryan on 12/11/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol NotifyFriendsDelegate {
    func sendGagWithSelectedFriends(friends: [PFUser])
}

class NotifyFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NotifyFriendsCellDelegate {
    
    // MARK: Properties
    // stores all the users that match the current search query
    var users: [PFUser]!
    @IBOutlet weak var barButtonSend: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var delegate: NotifyFriendsDelegate?
    
    var selectedFriends: [PFUser] = [PFUser]() {
        didSet {
            if (self.selectedFriends.count > 0) {
                self.barButtonSend.enabled = true
            } else {
                self.barButtonSend.enabled = false
            }
        }
    }
    
    // MARK: Actions
    @IBAction func send(sender: AnyObject) {
        self.delegate?.sendGagWithSelectedFriends(self.selectedFriends)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.users = [PFUser]()
        //self.selectedFriends = [PFUser]()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.getFriendsForUser(PFUser.currentUser()!, completionBlock: {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                self.users = objects as? [PFUser]
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("notifyFriendsCell") as! NotifyFriendsCell!
        if cell == nil {
            cell = NotifyFriendsCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "notifyFriendsCell")
        }
        
        let user = self.users[indexPath.row] as PFUser
        cell.labelUsername.text = user["username"] as? String
        cell.user = user
        cell.delegate = self
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotifyFriendsCell
        
        if (cell.friendSelected == true) {
            cell.friendSelected = false
        } else {
            cell.friendSelected = true
        }
    }
    
    func didSelectFriend(cell: NotifyFriendsCell) {
        let indexPath = self.tableView.indexPathForCell(cell)! as NSIndexPath
        let user = self.users[indexPath.row] as PFUser
        self.selectedFriends.append(user)
        print(self.selectedFriends)
    }
    
    func didDeselectFriend(cell: NotifyFriendsCell) {
        let index = self.selectedFriends.indexOf(cell.user!)
        self.selectedFriends.removeAtIndex(index!)
        print(self.selectedFriends)
    }
    

}
