//
//  FindFriendsCell.swift
//  GagTag
//
//  Created by Ryan on 9/20/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol FindFriendsCellDelegate: class {
    func cell(cell: FindFriendsCell, didSelectFriendUser user: PFUser)
    func cell(cell: FindFriendsCell, didSelectUnfriendUser user: PFUser)
}

class FindFriendsCell: UITableViewCell {
    
    
    @IBOutlet weak var buttonAction: UIButton!
    @IBOutlet weak var labelUsername: UILabel!
    weak var delegate: FindFriendsCellDelegate?
    
    var friend : PFUser!
    
    var user: PFUser? {
        didSet {
            labelUsername.text = user?.username
        }
    }
    
    enum RelationState {
        case Pending
    }
    
    var canFriend: Bool? = true {
        didSet {
            if let canFriend = canFriend where canFriend == true {
                buttonAction.setTitle("Add", forState: UIControlState.Normal)
            } else {
                buttonAction.setTitle("Remove", forState: UIControlState.Normal)
            }
        }
    }
    
    var isPending: Bool? = false {
        didSet {
            if let isPending = isPending where isPending == true {
                buttonAction.setTitle("Pending", forState: UIControlState.Normal)
            }
        }
    }
    
    @IBAction func add(sender: AnyObject) {
        if let canFriend = canFriend where canFriend == true {
            delegate?.cell(self, didSelectFriendUser: user!)
            self.canFriend = false
        } else {
            delegate?.cell(self, didSelectUnfriendUser: user!)
            self.canFriend = true
        }
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
