//
//  DiscoverViewController.swift
//  GagTag
//
//  Created by Ryan on 12/26/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class DiscoverViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var labelStatusBarBackground: UILabel!
    
    var gags: [PFObject]!
    var mainNavDelegate : MainNavDelegate?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        ParseHelper.getMyGagFeed({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                self.gags = objects
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    // MARK: Actions
    @IBAction func goToCamera(sender: AnyObject) {
        if let delegate = self.mainNavDelegate {
            delegate.goToController(1, direction: .Reverse, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.gags = [PFObject]()
        
        ParseHelper.getMyGagFeed({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                self.gags = objects
                self.collectionView.reloadData()
            }
        })
        
        
        // Add Refresh Control to TableView
        self.collectionView.addSubview(self.refreshControl)
        
        // Color
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.navBar.barTintColor = UIColor.MKColor.Orange
        self.labelStatusBarBackground.backgroundColor = UIColor.MKColor.Orange
    
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gags.count
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("discoverCell", forIndexPath: indexPath) as! DiscoverCell
        
        // Set gag object
        cell.gag = self.gags[indexPath.row] as PFObject
        
        // Query Gag image
        //cell.pfImage = gag["image"] as! PFFile
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! DiscoverCell
        let image = cell.imageView.image!
        
        let gag = self.gags[indexPath.row] as PFObject
        
        dispatch_async(dispatch_get_main_queue(), {
            self.showSingleGagView(gag, image: image)
        });
    
    }
    
    // MARK: Show Views
    func showSingleGagView(gag: PFObject, image: UIImage) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("singleGagView") as! SingleGagViewController
        vc.gagId = gag.objectId!
        vc.image = image
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
