//
//  GagFeedViewController.swift
//  GagTag
//
//  Created by Ryan on 10/5/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class GagFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    var gags : [PFObject]!
    var gagUserTag : PFObject!
    var mainNavDelegate : MainNavDelegate?
    @IBOutlet weak var tableView: UITableView!
    
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
        return 320
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("gagFeedCell") as! GagFeedCell!
        if cell == nil {
            cell = GagFeedCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "gagFeedCell")
        }
        
        // Default to nil to fix from displaying other tag in reused cell
        cell?.labelTag.text = nil
        cell?.imageView?.image = nil
        cell?.tagStatus = TagStatus.None
        
        
        let gag = self.gags[indexPath.row] as PFObject
        let pfimage = gag["image"] as! PFFile
        
        // Query Gag image
        pfimage.getDataInBackgroundWithBlock({
            (result, error) in
            if (result != nil) {
                cell?.gagImageView.image = UIImage(data: result!)
            }
        })
        
        // Display winningTag if it exsits
        // Else display chosentTag if it exists
        let winningTag = gag["winningTag"] as? PFObject
        if (winningTag != nil) {
            cell?.labelTag.text = winningTag?["value"] as? String
            cell?.tagStatus = TagStatus.WinningTagChosen
        } else {
            // Query Tags
            ParseHelper.getMyGagUserTagObjectForGag(gag) {
                (gagUserTag: PFObject?, error: NSError?) -> () in
                if (gagUserTag != nil) {
                    let chosenTag = gagUserTag?["chosenTag"] as? PFObject
                    if (chosenTag != nil) {
                        cell?.labelTag.text = "#" + (chosenTag?["value"] as? String)!
                        cell?.tagStatus = TagStatus.DealtTagChosen
                    }
                }
            }
        }
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Not sure why I have to use dispatch.  Explained in below StackOverflow
        // http://stackoverflow.com/questions/26165700/uitableviewcell-selection-storyboard-segue-is-slow-double-tapping-works-though
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GagFeedCell
        let tagStatus = cell.tagStatus
        let gag = self.gags[indexPath.row] as PFObject
        
        dispatch_async(dispatch_get_main_queue(), {
            
            switch (tagStatus) {
            case .WinningTagChosen:
                self.showGagUsersForGag(gag)
            case .DealtTagChosen:
                self.showGagUsersForGag(gag)
            case .None:
                self.showDealtTagsForGag(gag)
            }
            
        });
        
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
