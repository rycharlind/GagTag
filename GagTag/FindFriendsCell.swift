//
//  FindFriendsCell.swift
//  GagTag
//
//  Created by Ryan on 9/20/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class FindFriendsCell: UITableViewCell {
    
    
    @IBOutlet weak var buttonAction: UIButton!
    @IBOutlet weak var labelUsername: UILabel!
    var friend : PFObject!
    
    @IBAction func add(sender: AnyObject) {
        self.sendFriendRequest()
    }
    
    func sendFriendRequest() {
        var friend = PFObject(className: "Friends")
        friend.setObject(PFUser.currentUser()!, forKey: "user")
        friend.setObject(self.friend, forKey: "friend")
        friend.setObject(false, forKey: "approved")
        friend.setObject(false, forKey: "dismissed")
        friend.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                println("Friend added")
            } else {
                // There was a problem, check error.description
            }
        })
    }
    
    func removeFriend() {
        
        
        
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
