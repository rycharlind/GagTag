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
    var friend : PFUser!
    
    @IBAction func add(sender: AnyObject) {
        self.sendFriendRequest()
    }
    
    func sendFriendRequest() {
        
        let friendRequest = PFObject(className: "Friends")
        friendRequest.setObject(PFUser.currentUser()!, forKey: "user")
        friendRequest.setObject(self.friend, forKey: "friend")
        friendRequest.setObject(false, forKey: "approved")
        friendRequest.setObject(false, forKey: "dismissed")
        friendRequest.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("Friend added")
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
