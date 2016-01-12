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
        
        //self.backgroundColor = UIColor.MKColor.BlueGrey
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let f = pfImage {
            f.cancel()
        }
    }
    
}
