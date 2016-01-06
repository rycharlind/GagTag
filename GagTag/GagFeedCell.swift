//
//  GagFeedCell.swift
//  GagTag
//
//  Created by Ryan on 10/5/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol GagFeedCellDelegate: class {
    func didTouchTagsButton(cell: GagFeedCell)
    func didTouchUsersCountButton(cell: GagFeedCell)
}

class GagFeedCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var gagImageView: UIImageView!
    @IBOutlet weak var buttonTag: MKButton!
    @IBOutlet weak var buttonUsersCount: UIButton!
    var delegate: GagFeedCellDelegate?
    var gag: PFObject!
    
    // MARK: Actions
    @IBAction func buttonTagTouched(sender: AnyObject) {
        delegate?.didTouchTagsButton(self)
    }
    
    @IBAction func buttonUsersCountTouched(sender: AnyObject) {
        delegate?.didTouchUsersCountButton(self)
    }
    
    var gagState: GagState = .Waiting {
        didSet {
            switch(gagState) {
            case .ChoseDealtTag:
                print("ChoseDealtTag")
                self.footerView.backgroundColor = UIColor.MKColor.Blue
            case .ChoseWinningTag:
                print("ChoseWinningTag")
                self.footerView.backgroundColor = UIColor.MKColor.Purple
            case .Waiting:
                print("Waiting")
                self.footerView.backgroundColor = UIColor.MKColor.Orange
            case .Complete:
                print("Complete")
                self.footerView.backgroundColor = UIColor.MKColor.Green
            case .None:
                print("None")
                self.footerView.backgroundColor = UIColor.MKColor.Grey
                
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
