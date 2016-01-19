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

        self.imageView.backgroundColor = UIColor.grayColor()
    }
    
    var gag: PFObject? {
        didSet {
            if let gag = gag {
                self.pfImage = gag["image"] as? PFFile
            }
        }
    }
    
    var pfImage: PFFile? {
        didSet {
            if let f = pfImage {
                self.imageView.image = nil
                pfImage?.getDataInBackgroundWithBlock({
                    (result, error) in
                    if (result != nil) {
                        let image = UIImage(data: result!)
                        self.imageView.image = self.ResizeImage(image!, targetSize: CGSize(width: 300, height: 300))
                    }
                })
            }
        }
    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
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
