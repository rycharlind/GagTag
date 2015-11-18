//
//  FriendRequestsViewController.swift
//  GagTag
//
//  Created by Ryan on 10/4/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class FriendRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendRequestCellDelegate {

    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var friendRequests = [PFObject]()
    
    
    // MARK: Actions
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.getPendingFriendRequest({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                self.friendRequests = objects!
                self.tableView.reloadData()
            } else {
                print(error)
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendRequests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("friendRequestCell") as! FriendRequestCell!
        if cell == nil {
            cell = FriendRequestCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "friendRequestCell")
        }
        
        let friendRequest = self.friendRequests[indexPath.row] as PFObject
        cell?.friendRequest = friendRequest
        cell?.delegate = self
        
        let user = friendRequest["fromUser"] as! PFUser
        cell?.labelUsername?.text = user["username"] as? String
        cell?.friend = user
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    func cell(cell: FriendRequestCell, didApproveUser user: PFUser, friendRequest: PFObject) {
        print("approve")
        ParseHelper.addFriend(PFUser.currentUser()!, friend: user, completionBlock: nil)
        ParseHelper.addFriend(user, friend: PFUser.currentUser()!, completionBlock: nil)
        ParseHelper.updateFriendRequest(friendRequest, approved: true, dismissed: true, completionBlock: nil)
        cell.friendRequestStatus = RequestStatus.Accepted
    }
    
    func cell(cell: FriendRequestCell, didDismissUser user: PFUser, friendRequest: PFObject) {
        ParseHelper.updateFriendRequest(friendRequest, approved: false, dismissed: true, completionBlock: nil)
        cell.friendRequestStatus = RequestStatus.Dismissed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
