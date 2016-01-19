//
//  DealtTagsCell.swift
//  GagTag
//
//  Created by Ryan on 12/14/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class TagsCell: MKTableViewCell {
    
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var buttonRadioTag: UIButton!
    @IBOutlet weak var labelRadio: UILabel!
    var user: PFUser?
    
    var tagSelected: Bool = false {
        didSet {
            if (self.tagSelected == true) {
                labelRadio.text = GoogleIcon.eb35
            } else {
                labelRadio.text = GoogleIcon.eb33
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
