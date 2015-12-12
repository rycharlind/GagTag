//
//  NotifyFriendsCell.swift
//  GagTag
//
//  Created by Ryan on 12/11/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol NotifyFriendsCellDelegate {
    func didSelectFriend(cell: NotifyFriendsCell)
    func didDeselectFriend(cell: NotifyFriendsCell)
}

class NotifyFriendsCell: UITableViewCell {
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var buttonCheckFriend: UIButton!
    var user: PFUser?
    var delegate: NotifyFriendsCellDelegate?
    
    
    var friendSelected: Bool = false {
        didSet {
            if (self.friendSelected == true) {
                buttonCheckFriend.setTitle(GoogleIcon.eb2f, forState: .Normal) // Checked
                self.delegate?.didSelectFriend(self)
            } else {
                buttonCheckFriend.setTitle(GoogleIcon.eb31, forState: .Normal) // Unchecked
                self.delegate?.didDeselectFriend(self)
            }
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
