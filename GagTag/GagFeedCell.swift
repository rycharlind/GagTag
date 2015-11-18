//
//  GagFeedCell.swift
//  GagTag
//
//  Created by Ryan on 10/5/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit

enum TagStatus {
    case DealtTagChosen
    case WinningTagChosen
    case None
}

class GagFeedCell: UITableViewCell {
    
    @IBOutlet weak var gagImageView: UIImageView!
    @IBOutlet weak var labelTag: UILabel!
    
    
    var tagStatus: TagStatus = TagStatus.None {
        didSet {
            switch tagStatus {
            case .DealtTagChosen:
                print("DealtTagChosen")
                labelTag.backgroundColor = UIColor.blueColor()
            case .WinningTagChosen:
                print("WinningTagChosen")
                labelTag.backgroundColor = UIColor.greenColor()
            case .None:
                print("None")
                labelTag.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    
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
