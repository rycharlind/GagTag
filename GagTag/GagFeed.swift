//
//  GagFeedViewController.swift
//  GagTag
//
//  Created by Ryan on 10/5/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class GagFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GagFeedCellDelegate {

    // MARK: Properties
    var gags : [PFObject]!
    var gagUserTag : PFObject!
    var mainNavDelegate : MainNavDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barButtonCamera: UIBarButtonItem!
    
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
        self.navigationController?.navigationBar.tintColor = UIColor.red
        self.navigationController?.navigationBar.translucent = false
                
        if let font = UIFont(name: "googleicon", size: 20) {
            barButtonCamera.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            barButtonCamera.title = GoogleIcon.ea3e
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.queryGags()
        ParseHelper.getMyGagFeed({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                self.gags = objects
                self.tableView.reloadData()
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gags.count
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 454
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("gagFeedCell") as! GagFeedCell!
        if cell == nil {
            cell = GagFeedCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "gagFeedCell")
        }
        
        cell?.delegate = self
        
        // Default to nil to fix from displaying other tag in reused cell
        cell?.imageView?.image = nil
        cell.labelUsername?.text = nil
        cell.labelTag?.text = nil
        cell?.buttonNumberOfTags.setTitle("", forState: .Normal)
        
        // Set gag object
        let gag = self.gags[indexPath.row] as PFObject
        let allowedNumberOfTags = gag["allowedNumberOfTags"] as? Int
        cell?.gag = gag
        
        // Set username label
        let user = gag["user"] as! PFObject
        cell.labelUsername?.text = user["username"] as? String
        
        // Query Gag image
        let pfimage = gag["image"] as! PFFile
        pfimage.getDataInBackgroundWithBlock({
            (result, error) in
            if (result != nil) {
                cell?.gagImageView.image = UIImage(data: result!)
            }
        })
        
        let winningTag = gag["winningTag"] as? PFObject
        if (winningTag != nil) {
            cell.labelTag.text = "#" + (winningTag?["value"] as? String)!
            cell.tagStatus = TagStatus.WinningTagChosen
        } else {
            
            // Query My Gag User Tag
            ParseHelper.getMyGagUserTagObjectForGag(gag) {
                (gagUserTag: PFObject?, error: NSError?) -> () in
                if (gagUserTag != nil) {
                    let chosenTag = gagUserTag?["chosenTag"] as? PFObject
                    if (chosenTag != nil) {
                        cell.labelTag.text = "#" + (chosenTag?["value"] as? String)!
                        cell.tagStatus = TagStatus.DealtTagChosen
                    }
                }
            }
            
            // Check the count to see if allowedNumberOfTags is met
            ParseHelper.getTagCountForGag(gag, completionBlock: {
                (count: Int32, error: NSError?) -> Void in
                cell?.buttonNumberOfTags.setTitle("\(count) of \(allowedNumberOfTags!)", forState: .Normal)
                if (Int(count) == allowedNumberOfTags) {
                    cell.tagStatus = TagStatus.AllowedNumberOfTagsChosen
                }
            })
        }
        
        return cell
    
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Not sure why I have to use dispatch.  Explained in below StackOverflow
        // http://stackoverflow.com/questions/26165700/uitableviewcell-selection-storyboard-segue-is-slow-double-tapping-works-though
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GagFeedCell
        let tagStatus = cell.tagStatus
        let gag = self.gags[indexPath.row] as PFObject
        
        print(gag)
        
        dispatch_async(dispatch_get_main_queue(), {
            
            //self.showPreviewImageForImage(cell.gagImageView.image!)
            self.showSingleGagView(gag)
            
        });
        
    }
    
    // MARK GagFeedDelegate
    func cell(cell: GagFeedCell, didTouchTagsButton tagStatus: TagStatus, gag: PFObject) {
    
        let tagStatus = cell.tagStatus
        print(gag)
        //self.showSingleGagView(gag)
    
        //dispatch_async(dispatch_get_main_queue(), {
            
            switch (tagStatus) {
            case TagStatus.WinningTagChosen:
                self.showGagUsersForGag(gag)
            case .DealtTagChosen:
                self.showGagUsersForGag(gag)
            case .AllowedNumberOfTagsChosen:
                self.showGagUsersForGag(gag)
            case .None:
                self.showDealtTagsForGag(gag)
            }
            
        //});
    
    }
    
    func cell(cell: GagFeedCell, didTouchNumberOfTagsButton tagStatus: TagStatus, gag: PFObject) {
        self.showGagUsersForGag(gag)
    }
    
    func showSingleGagView(gag: PFObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("singleGagView") as! SingleGagViewController
        vc.gagId = gag.objectId!
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    func showPreviewImageForImage(image: UIImage) {
        let previewImageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("previewImageView") as! PreviewImageViewController
        previewImageViewController.image = image
        self.presentViewController(previewImageViewController, animated: false, completion: nil)
    }
    
    func showDealtTagsForGag(gag: PFObject) {
        let dealtTagsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("dealtTags") as! DealtTagsViewController
        dealtTagsViewController.gag = gag
        self.presentViewController(dealtTagsViewController, animated: true, completion: nil)
    }
    
    func showGagUsersForGag(gag: PFObject) {
        let gagUsersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gagUsers") as! GagUsersViewController
        gagUsersViewController.gag = gag
        self.presentViewController(gagUsersViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
