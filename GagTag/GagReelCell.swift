//
//  GagReelCell.swift
//  GagTag
//
//  Created by Ryan on 11/23/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

enum GagStatus {
    case WinningTagChosen
    case AllDealtTagsChosen
    case None
}

protocol GagReelCellDelegate: class {
    func cell(cell: GagReelCell, didTouchTagsButton gagStatus: GagStatus, gag: PFObject)
    func cell(cell: GagReelCell, didTouchNumberOfTagsButton gagStatus: GagStatus, gag: PFObject)
}

class GagReelCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var buttonNumberOfTags: UIButton!
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var gagImageView: UIImageView!
    @IBOutlet weak var buttonTag: MKButton!
    var delegate: GagReelCellDelegate?
    var gag: PFObject!
    
    // MARK: Actions
    @IBAction func gagReelButtonTagTouched(sender: AnyObject) {
        delegate?.cell(self, didTouchTagsButton: gagStatus, gag: gag)
    }
    
    @IBAction func gagReelButtonNumberOfTagsTouched(sender: AnyObject) {
        delegate?.cell(self, didTouchNumberOfTagsButton: gagStatus, gag: gag)
    }
    
    var gagStatus: GagStatus = GagStatus.None {
        didSet {
            switch gagStatus {
            case .AllDealtTagsChosen:
                print("All Dealt Tags Chosen")
            case .WinningTagChosen:
                print("Winning Tag Chosen")
            case .None:
                print("None")
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
