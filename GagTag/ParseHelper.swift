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
    
    
    // MARK: Users
    
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
    
    static func searchUsers(searchText: String, completionBlock: PFQueryArrayResultBlock)
        -> PFQuery {
            /*
            NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
            Regex can be slow on large datasets. For large amount of data it's better to store
            lowercased username in a separate column and perform a regular string compare.
            */
            let query = PFUser.query()!.whereKey("username", matchesRegex: searchText, modifiers: "i")
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
    
    // Add friend
    static func addFriend(user: PFUser, friend: PFUser, completionBlock: PFBooleanResultBlock?) {
        let queryCurrentUser = PFQuery(className: "Friends")
        queryCurrentUser.whereKey("user", equalTo: user)
        queryCurrentUser.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            
            var friends = PFObject(className: "Friends")
            
            if object != nil {
                friends = object!
            }
            
            friends["user"] = user
            
            let friendsRelation = friends.relationForKey("friends")
            friendsRelation.addObject(friend)
            
            friends.saveEventually(completionBlock)
            
        }
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
    
    static func getPendingFriendRequest(completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "FriendRequest")
        query.whereKey("toUser", equalTo: PFUser.currentUser()!)
        query.whereKey("approved", equalTo: false)
        query.whereKey("dismissed", equalTo: false)
        query.includeKey("fromUser")
        query.findObjectsInBackgroundWithBlock(completionBlock)
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
    
    static func getMyGagFeed(completionBlock: PFQueryArrayResultBlock) {
        ParseHelper.getFriendsForUser(PFUser.currentUser()!, completionBlock: {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil){
                let query = PFQuery(className: "Gag")
                query.whereKey("user", containedIn: objects!)
                query.includeKey("winningTag")
                query.orderByDescending("createdAt")
                query.findObjectsInBackgroundWithBlock(completionBlock)
            } else {
                print(error)
            }
        })
    }
    
    // MARK: Tags
    static func getMyGagUserTagObjectForGag(gag: PFObject, completionBlock: (gagUserTag: PFObject?, error: NSError?) ->()) {
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.whereKey("gag", equalTo: gag)
        query.includeKey("dealtTags")
        query.includeKey("chosenTag")
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            completionBlock(gagUserTag: object, error: error)
        })
    }
    
    static func getMyDealtTagsForGag(gag: PFObject, completionBlock: (tags: [PFObject]?, error: NSError?) ->()) {
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.whereKey("gag", equalTo: gag)
        query.includeKey("dealtTags")
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            print("gotMyDealtTags")
            let dealtTags = object?["dealtTags"] as? [PFObject]
            completionBlock(tags: dealtTags, error: error)
        })
    }
    
    static func getAllGagUserTagObjectsForGag(gag: PFObject, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: gag)
        query.includeKey("user")
        query.includeKey("dealtTags")
        query.includeKey("chosenTag")
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func getAllTagsExcludingDealtTagsObjectIds(dealtsTagsObjectIds: [String], completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "Tag")
        query.whereKey("objectId", notContainedIn: dealtsTagsObjectIds)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func getMyTagsForGag(gag: PFObject, completionBlock: (tags: [PFObject]?) -> ()) {
        ParseHelper.getMyDealtTagsForGag(gag, completionBlock: {
            (tags: [PFObject]?, error: NSError?) -> Void in
            if (error == nil  && tags != nil) {
                
                print("Tags are not nil")
                completionBlock(tags: tags)
                
                
            } else {
                
                ParseHelper.getAllGagUserTagObjectsForGag(gag, completionBlock: {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    print("gotAllGagUserTagObjects")
                    // concatenate all dealtTags
                    var dealtTags = [PFObject]()
                    for object in objects! {
                        let tags = object["dealtTags"] as? [PFObject]
                        dealtTags += tags!
                    }
                    
                    // append object ids to string array for query
                    var currentDealTagsObjectIds = [String]()
                    for dealtTag in dealtTags {
                        currentDealTagsObjectIds.append(dealtTag.objectId!)
                    }
                    
                    ParseHelper.getAllTagsExcludingDealtTagsObjectIds(currentDealTagsObjectIds, completionBlock: {
                        (objects: [PFObject]?, error: NSError?) -> Void in
                        if (error == nil) {
                            
                            let tags = ParseHelper.chooseRandomTagsFromTags(objects!)
                        
                            // Create new GagUserTag with newly dealtTags
                            let gagUserTag = PFObject(className: "GagUserTag")
                            gagUserTag["user"] = PFUser.currentUser()!
                            gagUserTag["gag"] = gag
                            gagUserTag["dealtTags"] = tags
                            gagUserTag.saveEventually()
                            
                            completionBlock(tags: tags)
                            
                        } else {
                            print(error)
                        }
                    })
                        

                
                })
            }
        })
    }
    
    static func chooseRandomTagsFromTags(var tags: [PFObject]) -> [PFObject] {
        var tempTags = [PFObject]()
        let numOfTags = 5
        for (var x = 0; x < numOfTags; x++) {
            let count = UInt32(tags.count)
            let index = Int(arc4random_uniform(count))
            tempTags.append(tags[index])
            tags.removeAtIndex(index)
        }
        return tempTags
    }
    
}