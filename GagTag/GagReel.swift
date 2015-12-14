//
//  ReelViewController.swift
//  GagTag
//
//  Created by Ryan on 9/10/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class GagReelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GagReelCellDelegate {

    // MARK: Properties
    var gags : [PFObject]!
    var gagUserTag : PFObject!
    var mainNavDelegate : MainNavDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barButtonCamera: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func goToCamera(sender: AnyObject) {
        if let delegate = self.mainNavDelegate {
            delegate.goToController(1, direction: .Forward, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.gags = [PFObject]()
        
    
        if let font = UIFont(name: "googleicon", size: 26) {
            barButtonCamera.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
            barButtonCamera.title = GoogleIcon.ea3e
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        ParseHelper.getMyGags({
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
        
        var cell = tableView.dequeueReusableCellWithIdentifier("gagReelCell") as! GagReelCell!
        if cell == nil {
            cell = GagReelCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "gagReelCell")
        }
        
        cell?.delegate = self
        
        // Default to nil to fix from displaying other tag in reused cell
        cell?.gagImageView?.image = nil
        cell?.labelTag.text = nil
        cell?.buttonNumberOfTags.setTitle("", forState: .Normal)
        
        let gag = self.gags[indexPath.row] as PFObject
        cell?.gag = gag
        
        let allowedNumberOfTags = gag["allowedNumberOfTags"] as? Int
        
        // Check the count to see if allowedNumberOfTags is met
        ParseHelper.getTagCountForGag(gag, completionBlock: {
            (count: Int32, error: NSError?) -> Void in
            cell?.buttonNumberOfTags.setTitle("\(count) of \(allowedNumberOfTags!)", forState: .Normal)
            if (Int(count) == allowedNumberOfTags) {
                cell.gagStatus = GagStatus.AllDealtTagsChosen
            }
        })
        
        if let tag = gag["winningTag"] as? PFObject {
            let value = tag["value"] as! String
            cell?.labelTag.text = "#" + value
            cell?.gagStatus = GagStatus.WinningTagChosen
        }
        
        // Query Gag Image
        let pfimage = gag["image"] as! PFFile
        pfimage.getDataInBackgroundWithBlock({
            (result, error) in
            if (error == nil) {
                cell?.gagImageView.image = UIImage(data: result!)
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        })
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let gag = self.gags[indexPath.row] as PFObject
        print(gag)
        
        dispatch_async(dispatch_get_main_queue(), {
            //self.showPreviewImageForImage(cell.gagImageView.image!)
            self.showSingleGagView(gag)
        });
    }
    
    // MARK:  GagReelCellDelegate
    func cell(cell: GagReelCell, didTouchTagsButton gagStatus: GagStatus, gag: PFObject) {
        switch gagStatus {
        case .AllDealtTagsChosen:
            print("All Dealt Tags Chosen")
            self.showChosenTagsForGag(gag)
        case .WinningTagChosen:
            print("Winning Tag Chosen")
        case .None:
            print("None")
        }
    }
    
    func cell(cell: GagReelCell, didTouchNumberOfTagsButton gagStatus: GagStatus, gag: PFObject) {
        self.showGagUsersForGag(gag)
    }
    
    func showGagUsersForGag(gag: PFObject) {
        let gagUsersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gagUsers") as! GagUsersViewController
        gagUsersViewController.gag = gag
        self.presentViewController(gagUsersViewController, animated: true, completion: nil)
    }
    
    func showSingleGagView(gag: PFObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("singleGagView") as! SingleGagViewController
        vc.gagId = gag.objectId!
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    func showChosenTagsForGag(gag: PFObject) {
        let chosenTagsVC = self.storyboard?.instantiateViewControllerWithIdentifier("chosenTags") as! ChosenTagsViewController
        chosenTagsVC.gag = gag
        self.presentViewController(chosenTagsVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
