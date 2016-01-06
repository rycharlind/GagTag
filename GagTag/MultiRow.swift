//
//  CollectionCell.swift
//  GagTag
//
//  Created by Ryan on 1/4/16.
//  Copyright © 2016 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol CollectionTableViewCellDelgate {
    func didCompleteQuery(objects: [PFObject])
}

class CollectionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var gags: [PFObject]!
    var delegate: CollectionTableViewCellDelgate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        self.gags = [PFObject]()
        
        ParseHelper.getMyGagFeed({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                self.delegate?.didCompleteQuery(objects!)
                self.gags = objects
                self.collectionView.reloadData()
            }
        })
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK:  UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = self.collectionView.frame.width - 2
        let size = width / 3
        return CGSize(width: size, height: size)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK:  UICollectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LargeCollectionCell", forIndexPath: indexPath) as! LargeCollectionCell
        
        cell.gagImageView?.image = nil
        
        // Set gag object
        let gag = self.gags[indexPath.row] as PFObject
        
        // Query Gag image
        let pfimage = gag["image"] as! PFFile
        pfimage.getDataInBackgroundWithBlock({
            (result, error) in
            if (result != nil) {
                cell.gagImageView.image = UIImage(data: result!)
            }
        })
        
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
    }

}
