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
    var friendRequest : PFObject!
    
    @IBAction func add(sender: AnyObject) {
        self.approve()
    }
    
    func approve() {
        var query = PFQuery(className: "Friends")
        query.getObjectInBackgroundWithId(self.friendRequest.objectId!, block: {
            (friend: PFObject?, error: NSError?) -> Void in
            if error != nil {
                println(error)
            } else if let friend = friend {
                friend["approved"] = true
                friend["dismissed"] = true
                friend.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        println("Friend Request Approved")
                    } else {
                        // There was a problem, check error.description
                    }
                })
            }
        })
    }
    
    func dismiss() {
        var query = PFQuery(className: "Friends")
        query.getObjectInBackgroundWithId(self.friendRequest.objectId!, block: {
            (friend: PFObject?, error: NSError?) -> Void in
            if error != nil {
                println(error)
            } else if let friend = friend {
                friend["approved"] = false
                friend["dismissed"] = true
                friend.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        println("Friend Request Approved")
                    } else {
                        // There was a problem, check error.description
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
