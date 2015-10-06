//
//  GagFeedCell.swift
//  GagTag
//
//  Created by Ryan on 10/5/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit

class GagFeedCell: UITableViewCell {
    
    @IBOutlet weak var gagImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.gagImageView.contentMode = .ScaleAspectFit
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
