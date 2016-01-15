//
//  DiscoverCell.swift
//  GagTag
//
//  Created by Ryan on 12/26/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class DiscoverCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var pfImage: PFFile? {
        didSet {
            if let f = pfImage {
                pfImage?.getDataInBackgroundWithBlock({
                    (result, error) in
                    if (result != nil) {
                        self.imageView.image = UIImage(data: result!)
                    }
                })
            }
        }
    }
    
    var gagState: GagState = .Waiting {
        didSet {
            switch(gagState) {
            case .ChoseDealtTag:
                print("ChoseDealtTag")
            case .ChoseWinningTag:
                print("ChoseWinningTag")
            case .Waiting:
                print("Waiting")
            case .Complete:
                print("Complete")
            case .None:
                print("None")
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let f = pfImage {
            f.cancel()
        }
    }
    
}
