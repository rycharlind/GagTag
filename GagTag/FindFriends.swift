//
//  FriendsViewController.swift
//  GagTag
//
//  Created by Ryan on 9/20/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class FindFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FindFriendsCellDelegate {
    
    // MARK: Properties
    // stores all the users that match the current search query
    var users: [PFUser]?
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: Actions
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    This is a local cache. It stores all the users this user is following.
    It is used to update the UI immediately upon user interaction, instead of waiting
    for a server response.
    */
    var friendUsers: [PFUser]? {
        didSet {
            /**
            the list of following users may be fetched after the tableView has displayed
            cells. In this case, we reload the data to reflect "following" status
            */
            tableView.reloadData()
        }
    }
    
    var pendingUsers: [PFUser]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    // the current parse query
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            oldValue?.cancel()
        }
    }
    
    // this view can be in two different states
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    
    // whenever the state changes, perform one of the two queries and update the list
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                query = ParseHelper.allUsers(updateList)
                
            case .SearchMode:
                query = ParseHelper.allUsers(updateList)
                //let searchText = searchBar?.text ?? ""
                //query = ParseHelper.searchUsers(searchText, completionBlock:updateList)
            }
        }
    }
    
    func updateList(objects: [PFObject]?, error: NSError?) {
        self.users = objects as? [PFUser] ?? []
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.users = [PFUser]()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        state = .DefaultMode
        
        ParseHelper.getFriendsForUser(PFUser.currentUser()!, completionBlock: {
            (objects: [PFObject]?, errror: NSError?) -> Void in
            self.friendUsers = objects as? [PFUser]
            print(self.friendUsers)
        })
    
        ParseHelper.getPendingFriendRequestUsers({
            (users: [PFUser]) -> Void in
            self.pendingUsers = users
            print(self.pendingUsers)
        })

    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("findFriendsCell") as! FindFriendsCell!
        if cell == nil {
            cell = FindFriendsCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "findFriendscell")
        }
        
        let user = users![indexPath.row]
        cell.user = user
        cell.relationshipStatus = Relationship.None
        cell.delegate = self
        
        // Check if user is a friend
        if let friendUsers = friendUsers {
            //cell.canFriend = !friendUsers.contains(user)
            if friendUsers.contains(user) {
               cell.relationshipStatus = Relationship.Friends
            }
        }
        
        // Check if you have a pending friend request
        if let pendingUsers = pendingUsers {
            //cell.isPending = pendingUsers.contains(user)
            if pendingUsers.contains(user) {
                cell.relationshipStatus = Relationship.Pending
            }
        }
        
        return cell
        
    }
    
    // MARK: FindFriendsCellDelegate
    func cell(cell: FindFriendsCell, didSelectFriendUser user: PFUser) {
        ParseHelper.sendFriendRequestToUser(user, completionBlock: nil)
        pendingUsers?.append(user)
    }
    
    func cell(cell: FindFriendsCell, didSelectUnfriendUser user: PFUser) {
        ParseHelper.removeFriend(user, completionBlock: nil)
        let index = friendUsers?.indexOf(user)
        friendUsers?.removeAtIndex(index!)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
