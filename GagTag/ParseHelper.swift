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
        query.cachePolicy = PFCachePolicy.CacheElseNetwork
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
    
    // Query all friends
    // Retun in Dictionary format
    static func getFriendsDictionaryForUser(user: PFUser, completionBlock: (userDict: [String:[PFUser]]) -> ()) -> PFQuery {
        let query = PFQuery(className: "Friends")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                let relation = object?.relationForKey("friends")
                let q = relation?.query()
                q?.orderByAscending("username")
                q?.findObjectsInBackgroundWithBlock({
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if (objects != nil) {
                        
                        var userDict = [String:[PFUser]]()
                        
                        // Populate unsorted dictionary
                        for object in objects! {
                            let user = object as! PFUser
                            let username = user["username"] as! String
                            
                            if let ch = username.characters.first {
                                let firstLetter = String(ch)
                                let firstLetterUpper = firstLetter.uppercaseString
                                if let _ = userDict[firstLetterUpper] {
                                    userDict[firstLetterUpper]!.append(user)
                                } else {
                                    var newUsers = [PFUser]()
                                    newUsers.append(user)
                                    userDict[firstLetterUpper] = newUsers
                                }
                            }
                        }
                
                        completionBlock(userDict: userDict)

                    
                    }
                })
            } else {
                print(error)
            }
        })
        return query
    }
    
    // Query all friends
    static func searchFriendsDictionaryForUser(searchText: String, user: PFUser, completionBlock: (userDict: [String:[PFUser]]) ->()) -> PFQuery {
        let query = PFQuery(className: "Friends")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if (error == nil) {
                let relation = object?.relationForKey("friends")
                let q = relation?.query()
                q?.whereKey("username", matchesRegex: searchText, modifiers: "i")
                q?.orderByAscending("username")
                q?.findObjectsInBackgroundWithBlock({
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if (objects != nil) {
                        
                        var userDict = [String:[PFUser]]()
                        
                        // Populate unsorted dictionary
                        for object in objects! {
                            let user = object as! PFUser
                            let username = user["username"] as! String
                            
                            if let ch = username.characters.first {
                                let firstLetter = String(ch)
                                let firstLetterUpper = firstLetter.uppercaseString
                                if let _ = userDict[firstLetterUpper] {
                                    userDict[firstLetterUpper]!.append(user)
                                } else {
                                    var newUsers = [PFUser]()
                                    newUsers.append(user)
                                    userDict[firstLetterUpper] = newUsers
                                }
                            }
                        }
                        
                        completionBlock(userDict: userDict)
                        
                    }
                })
                
            } else {
                print(error)
            }
        })
        return query
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
    static func getGagWithId(id: String, completionBlock: PFObjectResultBlock) {
        let query = PFQuery(className:"Gag")
        query.includeKey("user")
        query.getObjectInBackgroundWithId(id) {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil && object != nil {
                print(object)
                completionBlock(object, error)
            } else {
                print(error)
            }
        }
    }
    
    static func getMyGags(completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "Gag")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.includeKey("winningTag")
        query.orderByDescending("createdAt")
        query.cachePolicy = PFCachePolicy.CacheElseNetwork
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func getMyGagFeed(completionBlock: PFQueryArrayResultBlock) {
        ParseHelper.getFriendsForUser(PFUser.currentUser()!, completionBlock: {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil){
                let query = PFQuery(className: "Gag")
                
                query.whereKey("user", containedIn: objects!)
                query.includeKey("winningTag")
                query.includeKey("user")
                query.orderByDescending("createdAt")
                query.cachePolicy = PFCachePolicy.CacheElseNetwork
                //query.limit = 12
                
                query.findObjectsInBackgroundWithBlock(completionBlock)
            } else {
                print(error)
            }
        })
    }
    
    static func getMyGagFeedForPageIndex(pageIndex: Int, count: Int, friends: [PFObject], completionBlock: PFQueryArrayResultBlock) {
        
        let query = PFQuery(className: "Gag")
        query.limit = count;
        query.skip  = pageIndex * (count + 1);
        query.whereKey("user", containedIn: friends)
        query.includeKey("winningTag")
        query.includeKey("user")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock(completionBlock)
    
    
    }
    
    static func saveImage(image: UIImage, numberOfTags: Int, friends: [PFUser], completionBlock: PFBooleanResultBlock, progressBlock: (percentDone: Int32) ->()) {
        
        let imageData = image.lowQualityJPEGNSData
        let imageFile = PFFile(name:"photo.png", data:imageData)
        imageFile!.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            completionBlock(succeeded, error)
            if (succeeded) {
                let gag = PFObject(className:"Gag")
                gag["user"] = PFUser.currentUser()
                gag["allowedNumberOfTags"] = numberOfTags
                gag["image"] = imageFile
                gag["friends"] = friends
                gag.saveEventually({
                    (succeeded: Bool, error: NSError?) -> Void in
                    if (succeeded) {
                        print("Gag Saved Sucessfully")
                    } else {
                        print(error)
                    }
                })
            }
            },progressBlock: {
                (percentDone: Int32) -> Void in
                progressBlock(percentDone: percentDone)
        })
    }
    
    static func getMyNotifications(completionBlock: PFQueryArrayResultBlock) {

        let queryGagsToMe = PFQuery(className: "Gag")
        queryGagsToMe.whereKey("friends", equalTo: PFUser.currentUser()!)
        
        let queryGagsFromMe = PFQuery(className: "Gag")
        queryGagsFromMe.whereKey("user", equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([queryGagsToMe, queryGagsFromMe])
        query.cachePolicy = PFCachePolicy.CacheElseNetwork
        query.includeKey("user")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock(completionBlock)
    
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
    
    // GET - All GagUserTag objects
    static func getAllGagUserTagObjectsForGag(gag: PFObject, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "GagUserTag")
        query.cachePolicy = PFCachePolicy.CacheElseNetwork
        query.whereKey("gag", equalTo: gag)
        query.includeKey("user")
        query.includeKey("dealtTags")
        query.includeKey("chosenTag")
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    // GET - All GagUserTag objects with limit and chosenTag exists ordered by createdAt
    static func getAllGagUserTagObjectsForGag(gag: PFObject, limit: Int, completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "GagUserTag")
        query.cachePolicy = PFCachePolicy.CacheElseNetwork
        query.whereKey("gag", equalTo: gag)
        query.limit = limit
        query.orderByAscending("createdAt")
        query.whereKeyExists("chosenTag")
        query.includeKey("user")
        query.includeKey("dealtTags")
        query.includeKey("chosenTag")
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    // GET - Winning User
    static func getWinningUserForGag(gag: PFObject, completionBlock: (user: PFUser?) -> ()) {
        let winningTag = gag["winningTag"] as! PFObject
        ParseHelper.getAllGagUserTagObjectsForGag(gag, completionBlock: {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                for object in objects! {
                    if let chosenTag = object["chosenTag"] {
                        if (winningTag.objectId == chosenTag.objectId) {
                            let user = object["user"] as! PFUser
                            completionBlock(user: user)
                        }
                    }
                }
            }
        })
    }
    
    static func getAllTagsExcludingDealtTagsObjectIds(dealtsTagsObjectIds: [String], completionBlock: PFQueryArrayResultBlock) {
        let query = PFQuery(className: "Tag")
        query.whereKey("objectId", notContainedIn: dealtsTagsObjectIds)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func getTagCountForGag(gag: PFObject, completionBlock: PFIntegerResultBlock) {
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: gag)
        
        // Have to query for all gagUserTag objects and check if a chosenTag exists
        // A GagUserTag record is created when tags are dealt.  It does not mean a user has chosen a tag
        // So you CANNOT just count the number of records
        //query.countObjectsInBackgroundWithBlock(completionBlock)
        
        
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
                    // concatenate all dealtTags
                    var dealtTags = [PFObject]()
                    for object in objects! {
                        let tags = object["dealtTags"] as! [PFObject]
                        dealtTags += tags
                        print(object)
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
    
    static func getChosenTagsForGag(gag: PFObject, limit: Int, completionBlock: (tags: [PFObject]?) -> ()) {
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: gag)
        query.whereKeyExists("chosenTag")
        query.limit = limit
        query.includeKey("chosenTag")
        query.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                var tags = [PFObject]()
                for object in objects! {
                    let chosenTag = object["chosenTag"] as! PFObject
                    tags.append(chosenTag)
                }
                completionBlock(tags: tags)
            }
        })
    }
    
    static func sendWinningTagForGag(gag: PFObject, tag: PFObject, completionBlock: PFBooleanResultBlock) {
        gag.fetchIfNeededInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if (object != nil) {
                object?["winningTag"] = tag
                object?.saveEventually(completionBlock)
            }
        })
    }
    
}