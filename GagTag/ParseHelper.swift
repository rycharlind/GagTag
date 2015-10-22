//
//  ParseHelper.swift
//  GagTag
//
//  Created by Ryan on 10/19/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    
    // MARK: Friends
    
    // Query all users
    static func allUsers(completionBlock: PFQueryArrayResultBlock) -> PFQuery {
        
        let query = PFUser.query()!
        
        // exclude the current user
        query.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending("username")
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
        
    }
    
    // Query all friends
    static func getFriendsForUser(user: PFUser, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "Friends")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                let relation = object?.relationForKey("friends")
                let q = relation?.query()
                q?.findObjectsInBackgroundWithBlock(completionBlock)
            } else {
                print(error)
            }
        })
    
    }
    
    // Send a friend request
    static func sendFriendRequestToUser(user: PFUser, completionBlock: PFBooleanResultBlock?) {
        let friendRequest = PFObject(className: "FriendRequest")
        friendRequest["fromUser"] = PFUser.currentUser()!
        friendRequest["toUser"] = user
        friendRequest["approved"] = false
        friendRequest["dismissed"] = false
        friendRequest.saveEventually(completionBlock)
    }
    
    static func removeFriend(user: PFUser, completionBlock: PFBooleanResultBlock?) {
        let query = PFQuery(className: "Friends")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                let relation = object?.relationForKey("friends")
                relation?.removeObject(user)
                object?.saveEventually(completionBlock)
            } else {
                print(error)
            }
        })
    }
    
    // Update friend request
    static func updateFriendRequest(friendRequest: PFObject, approved: Bool, dismissed: Bool, completionBlock: PFBooleanResultBlock?) {
        friendRequest["approved"] = approved
        friendRequest["dismissed"] = dismissed
        friendRequest.saveEventually(completionBlock)
    }
    
    // Get pending friend request
    static func getPendingFriendRequestUsers(completionBlock: (users: [PFUser]) ->()) {
        let query = PFQuery(className: "FriendRequest")
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        query.whereKey("approved", equalTo: false)
        query.whereKey("dismissed", equalTo: false)
        query.includeKey("toUser")
        query.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            // map out the users and pass to completionBlock
            
            var users = [PFUser]()
            for object in objects! {
                let user = object["toUser"] as! PFUser
                users.append(user)
            }
            
            completionBlock(users: users)
        
        
        })
    }
    
    
    // MARK: Gags
    static func getMyGags(completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "Gag")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.includeKey("winningTag")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
    }
    
}