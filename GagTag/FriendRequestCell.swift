//
//  FriendRequestCell.swift
//  GagTag
//
//  Created by Ryan on 10/4/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class FriendRequestCell: UITableViewCell {
    
    @IBOutlet weak var buttonAction: UIButton!
    @IBOutlet weak var labelUsername: UILabel!
    var friend : PFUser!
    
    @IBAction func add(sender: AnyObject) {
        self.approve()
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismiss()
    }
    
    func approve() {
        print("approve")
        
        // Update/Add friend for Current User
        let queryCurrentUser = PFQuery(className: "Friends")
        queryCurrentUser.whereKey("user", equalTo: PFUser.currentUser()!)
        queryCurrentUser.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
            
                let friends = PFObject(className: "Friends")
                self.addFriend(friends, user: PFUser.currentUser()!, friend: self.friend)
            
            } else {
                
                self.addFriend(object!, user: PFUser.currentUser()!, friend: self.friend)
                
            }
        }
        
        // Update/Add friend for FromUser (User who sent the friend request)
        let queryFromUser = PFQuery(className: "Friends")
        queryFromUser.whereKey("user", equalTo: self.friend)
        queryFromUser.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                
                let friends = PFObject(className: "Friends")
                self.addFriend(friends, user: self.friend, friend: PFUser.currentUser()!)
                
            } else {
                
                self.addFriend(object!, user: self.friend, friend: PFUser.currentUser()!)
                
            }
        }
        
        self.updateFriendRequest(true)

    }
    
    func dismiss() {
        
    }
    
    func addFriend(friends: PFObject, user: PFObject, friend: PFObject) {
        friends["user"] = user
        
        let friendsRelation = friends.relationForKey("friends")
        friendsRelation.addObject(friend)
        
        friends.saveEventually({
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("Friend Added")
            } else {
                // There was a problem, check error.description
                print(error)
            }
        })
        
    }
    
    func updateFriendRequest(approved: Bool) {
        let query = PFQuery(className: "FriendRequest")
        query.whereKey("fromUser", equalTo: self.friend)
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print(error)
            } else if let friendRequest = object {
                friendRequest["approved"] = approved
                friendRequest.saveEventually({
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("Friend Request Updated")
                    }
                })
            }
        })
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
