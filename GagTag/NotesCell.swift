//
//  NotesCell.swift
//  GagTag
//
//  Created by Ryan on 1/19/16.
//  Copyright © 2016 Inndevers. All rights reserved.
//

import UIKit
import Parse

public enum NoteType {
    case Gag, FriendRequest
}

class NotesCell: UITableViewCell {
    
    @IBOutlet weak var imageViewGag: UIImageView!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelCreatedAt: UILabel!
    var viewed: Bool!
    
    var noteType: NoteType = .Gag {
        didSet {
            switch noteType {
            case .Gag:
                print("Gag")
                
            case .FriendRequest:
                print("FriendRequest")
            }
        }
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
                self.imageViewGag.image = nil
                pfImage?.getDataInBackgroundWithBlock({
                    (result, error) in
                    if (result != nil) {
                        let image = UIImage(data: result!)
                        self.imageViewGag.image = self.ResizeImage(image!, targetSize: CGSize(width: 100, height: 100))
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imageViewGag.layer.cornerRadius = 5
        self.imageViewGag.layer.masksToBounds = true
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
