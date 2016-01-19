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
    var friends: [PFUser]!
    var mainNavDelegate : MainNavDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barButtonCamera: UIBarButtonItem!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    // MARK: Actions
    @IBAction func goToCamera(sender: AnyObject) {
        if let delegate = self.mainNavDelegate {
            delegate.goToController(1, direction: .Reverse, animated: true)
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        ParseHelper.getMyGagFeed({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                self.gags = objects
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.gags = [PFObject]()
        self.navigationController?.navigationBar.tintColor = UIColor.red
        self.navigationController?.navigationBar.translucent = false
        
        // Add Refresh Control to TableView
        self.tableView.addSubview(self.refreshControl)
                
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
        
        /*
        ParseHelper.getMyGagFeedForPageIndex(0, count: 25, friends: self.friends, completionBlock: {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            
        })
        */
        
        
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
        cell?.gagImageView?.image = nil
        cell.labelUsername?.text = nil
        cell.labelTag?.text = nil
        cell?.buttonUsersCount.setTitle("", forState: .Normal)
        cell?.buttonTag.hidden = false
        
        // Set gag object
        let gag = self.gags[indexPath.row] as PFObject
        cell?.gag = gag
        
        // Set allowedNumberOfTags
        let allowedNumberOfTags = gag["allowedNumberOfTags"] as! Int
        
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
        
        
        if let winningTag = gag["winningTag"] {
            let value = winningTag["value"] as! String
            cell.labelTag.text = " #\(value)"
            cell.gagState = GagState.Complete
            cell.buttonTag.hidden = true
        }
        
        ParseHelper.getAllGagUserTagObjectsForGag(gag, limit: allowedNumberOfTags, completionBlock: {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                
                // Set buttonNumberOfTags text
                cell?.buttonUsersCount.setTitle("\(objects!.count) of \(allowedNumberOfTags)", forState: .Normal)
                
                
                // Check Tags
                if (objects?.count == allowedNumberOfTags) {
                    if let _ = gag["winningTag"] {
                        cell.gagState = GagState.Complete
                    } else {
                        let user = gag["user"] as! PFUser
                        if (user.objectId == PFUser.currentUser()!.objectId) {
                            cell.gagState = GagState.ChoseWinningTag
                        } else {
                            cell.gagState = GagState.Waiting
                        }
                    }
                } else {
                    let user = gag["user"] as! PFUser
                    if (user.objectId == PFUser.currentUser()!.objectId) {
                        cell.gagState = GagState.Waiting
                    } else {
                        cell.gagState = GagState.ChoseDealtTag
                        for gagUserTag in objects! {
                            let user = gagUserTag["user"] as! PFUser
                            if (user.objectId == PFUser.currentUser()!.objectId) {
                                cell.gagState = GagState.Waiting
                            }
                        }
                    }
                }
                
                
                /*
                // Count number of tags chosent
                var numberOfTagsChosen = 0
                for object in objects! {
                    if let chosenTag = object["chosenTag"] {
                        numberOfTagsChosen++
                        
                        //Check if currentUser has a chosenTag
                        let user = object["user"] as! PFUser
                        if (user.objectId == PFUser.currentUser()!.objectId) {
                            let value = chosenTag["value"] as! String
                            cell.labelTag.text = " #\(value)"
                            cell.tagStatus = TagStatus.DealtTagChosen
                            cell.buttonTag.hidden = true
                        }
                    }
                }
                */
                
                
            }
            
            if (error != nil) {
                print(error)
            }
        })
        
        return cell
    
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let gag = self.gags[indexPath.row] as PFObject
        
        dispatch_async(dispatch_get_main_queue(), {
            self.showSingleGagView(gag)
        });
        
    }
    
    // MARK GagFeedDelegate
    func didTouchTagsButton(cell: GagFeedCell) {
        self.showDealtTagsForGag(cell.gag)
    }
    
    func didTouchUsersCountButton(cell: GagFeedCell) {
        self.showGagUsersForGag(cell.gag)
    }
    
    // MARK: Show Views
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
        let dealtTagsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tags") as! TagsViewController
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
