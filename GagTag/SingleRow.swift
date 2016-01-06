//
//  SingleRowCollectionCell.swift
//  GagTag
//
//  Created by Ryan on 1/4/16.
//  Copyright © 2016 Inndevers. All rights reserved.
//

import UIKit
import Parse

class SingleRowCollectionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var gags: [PFObject]!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        self.gags = [PFObject]()
        
        ParseHelper.getMyGagFeed({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
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
        
        return CGSize(width: 75, height: 75)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 1, bottom: 1, right: 1)
    }
    
    // MARK:  UICollectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.gags.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MediumCollectionCell", forIndexPath: indexPath) as! MediumCollectionCell
        
        cell.gagImageView?.image = nil
        
        // Set gag object
        let gag = self.gags[indexPath.section] as PFObject
        
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
