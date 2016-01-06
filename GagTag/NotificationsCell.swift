//
//  NotificationsCell.swift
//  GagTag
//
//  Created by Ryan on 12/20/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit

enum GagState {
    case None
    case ChoseDealtTag
    case ChoseWinningTag
    case Waiting
    case Complete
}

class NotificationsCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var labelIcon: UILabel!
    @IBOutlet weak var labelFromUsername: UILabel!
    @IBOutlet weak var labelUsers: UILabel!
    @IBOutlet weak var labelUsersCount: UILabel!
    @IBOutlet weak var labelCreatedAt: UILabel!
    
    var gagState: GagState = .Waiting {
        didSet {
            switch(gagState) {
            case .ChoseDealtTag:
                print("ChoseDealtTag")
                self.labelIcon.text = GoogleIcon.eb78
                self.labelIcon.textColor = UIColor.MKColor.Blue
            case .ChoseWinningTag:
                print("ChoseWinningTag")
                self.labelIcon.text = GoogleIcon.eb78
                self.labelIcon.textColor = UIColor.MKColor.Purple
            case .Waiting:
                print("Waiting")
                self.labelIcon.text = GoogleIcon.e750
                self.labelIcon.textColor = UIColor.MKColor.Orange
            case .Complete:
                print("Complete")
                self.labelIcon.text = GoogleIcon.e64b
                self.labelIcon.textColor = UIColor.MKColor.Green
            case .None:
                print("None")
                self.labelIcon.text = nil
                
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
