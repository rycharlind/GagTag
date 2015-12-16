//
//  GagFeedCell.swift
//  GagTag
//
//  Created by Ryan on 10/5/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

enum TagStatus {
    case DealtTagChosen
    case WinningTagChosen
    case None
}

protocol GagFeedCellDelegate: class {
    func cell(cell: GagFeedCell, didTouchTagsButton tagStatus: TagStatus, gag: PFObject)
    func cell(cell: GagFeedCell, didTouchNumberOfTagsButton tagStatus: TagStatus, gag: PFObject)
}

class GagFeedCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var buttonNumberOfTags: UIButton!
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var gagImageView: UIImageView!
    @IBOutlet weak var buttonTag: MKButton!
    var delegate: GagFeedCellDelegate?
    var gag: PFObject!
    
    // MARK: Actions
    @IBAction func buttonTagTouched(sender: AnyObject) {
        delegate?.cell(self, didTouchTagsButton: tagStatus, gag: gag)
    }
    
    @IBAction func buttonNumberOfTagsTouched(sender: AnyObject) {
        delegate?.cell(self, didTouchNumberOfTagsButton: tagStatus, gag: gag)   
    }
    
    var tagStatus: TagStatus = TagStatus.None {
        didSet {
            switch tagStatus {
            case .DealtTagChosen:
                print("")
            case .WinningTagChosen:
                print("")
            case .None:
                print("")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        // Init Button Tags
        buttonTag.cornerRadius = 0.5 * buttonTag.bounds.size.width
        buttonTag.layer.shadowOpacity = 0.75
        buttonTag.layer.shadowRadius = 3.5
        buttonTag.layer.shadowColor = UIColor.blackColor().CGColor
        buttonTag.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)
        
        gagImageView.contentMode = .ScaleAspectFit
        
        containerView.layer.cornerRadius = 4
        containerView.layer.masksToBounds = true
        
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOpacity = 0.75
        headerView.layer.shadowOffset = CGSizeZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
