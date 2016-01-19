//
//  AddTagCell.swift
//  GagTag
//
//  Created by Ryan on 1/17/16.
//  Copyright © 2016 Inndevers. All rights reserved.
//

import UIKit
import Parse

class AddTagCell: MKTableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var labelRadio: UILabel!
    var gag: PFObject!
    
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
