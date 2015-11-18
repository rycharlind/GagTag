//
//  FriendRequestCell.swift
//  GagTag
//
//  Created by Ryan on 10/4/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol FriendRequestCellDelegate: class {
    func cell(cell: FriendRequestCell, didApproveUser user: PFUser, friendRequest: PFObject)
    func cell(cell: FriendRequestCell, didDismissUser user: PFUser, friendRequest: PFObject)
}

enum RequestStatus {
    case Pending
    case Accepted
    case Dismissed
}

class FriendRequestCell: UITableViewCell {
    
    weak var delegate: FriendRequestCellDelegate?
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var buttonNo: UIButton!
    var friendRequest: PFObject!
    var friend : PFUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var friendRequestStatus: RequestStatus = RequestStatus.Pending {
        didSet {
            switch friendRequestStatus {
            case .Pending:
                print("pending")
                buttonNo.hidden = false
                buttonYes.hidden = false
            case .Accepted:
                print("accepted")
                labelUsername.text = labelUsername.text! + " - Approved"
                buttonNo.hidden = true
                buttonYes.hidden = true
            case .Dismissed:
                print("dismissed")
                labelUsername.text = labelUsername.text! + " - Declined"
                buttonNo.hidden = true
                buttonYes.hidden = true
            }
        }
    }
    
    @IBAction func approve(sender: AnyObject) {
        delegate?.cell(self, didApproveUser: self.friend, friendRequest: self.friendRequest)
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        delegate?.cell(self, didDismissUser: self.friend, friendRequest: self.friendRequest)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
