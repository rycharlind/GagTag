//
//  DealtTagsCell.swift
//  GagTag
//
//  Created by Ryan on 12/14/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class DealtTagsCell: MKTableViewCell {
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var buttonRadioTag: UIButton!
    var user: PFUser?
    
    var tagSelected: Bool = false {
        didSet {
            if (self.tagSelected == true) {
                buttonRadioTag.setTitle(GoogleIcon.eb35, forState: .Normal) // Checked
                //self.delegate?.didSelectFriend(self)
            } else {
                buttonRadioTag.setTitle(GoogleIcon.eb33, forState: .Normal) // Unchecked
                //self.delegate?.didDeselectFriend(self)
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
