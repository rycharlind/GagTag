//
//  NotificationsViewController.swift
//  GagTag
//
//  Created by Ryan on 12/20/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barButtonCamera: UIBarButtonItem!
    var gags: [PFObject]!
    var mainNavDelegate : MainNavDelegate?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    // MARK: Actions
    @IBAction func goToCamera(sender: AnyObject) {
        if let delegate = self.mainNavDelegate {
            delegate.goToController(1, direction: .Forward, animated: true)
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        ParseHelper.getMyNotifications({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                print(objects)
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
        ParseHelper.getMyNotifications({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                print(objects)
                self.gags = objects
                self.tableView.reloadData()
            }
        })
        
        self.tableView.addSubview(self.refreshControl)

    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gags.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("notificationsCell") as! NotificationsCell!
        if cell == nil {
            cell = NotificationsCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "notificationsCell")
        }
        
        
        cell.labelIcon.text = nil
        cell.labelFromUsername.text = nil
        cell.labelUsers.text = nil
        cell.labelUsersCount.text = nil
        cell.gagState = GagState.None
        

        let gag = self.gags[indexPath.row] as PFObject
        
        let user = gag["user"] as! PFUser
        let allowedNumberOfTags = gag["allowedNumberOfTags"] as! Int
        
        // Set labelUsername
        cell.labelFromUsername.text = user["username"] as? String
        
        // Set labelCreatedAt
        let dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let dateString = dateFormatter.stringFromDate(gag.createdAt!)
        cell.labelCreatedAt.text = dateString
        
        // Check for winningTag
        if let _ = gag["winningTag"] {
            cell.gagState = GagState.Complete
        }
        
        // Query All GagUserTag objects - with limit
        ParseHelper.getAllGagUserTagObjectsForGag(gag, limit: allowedNumberOfTags, completionBlock: {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                
                // Set labelUsersCount
                cell.labelUsersCount.text = "\(objects!.count) of \(allowedNumberOfTags)"
                
                // Set labelUsers
                var text = ""
                for gagUserTag in objects! {
                    // Only show users have submitted a chosenTag
                    if let chosenTag = gagUserTag["chosenTag"] {
                        let user = gagUserTag["user"] as! PFUser
                        let username = user["username"] as! String
                        if text.isEmpty {
                            text = username
                        } else {
                            text += " \(username)"
                        }
                    }
                }
                cell.labelUsers.text = text
                
                
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
    
    // MARK: Show Views
    func showSingleGagView(gag: PFObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("singleGagView") as! SingleGagViewController
        vc.gagId = gag.objectId!
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    

}
