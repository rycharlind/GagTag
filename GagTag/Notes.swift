//
//  NotesViewController.swift
//  GagTag
//
//  Created by Ryan on 1/19/16.
//  Copyright © 2016 Inndevers. All rights reserved.
//

import UIKit
import Parse

class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notes: [PFObject]!
    var mainNavDelegate : MainNavDelegate?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        ParseHelper.getMyNotes({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                self.notes = objects
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    // MARK: Actions
    @IBAction func goToCamera(sender: AnyObject) {
        if let delegate = self.mainNavDelegate {
            delegate.goToController(1, direction: .Forward, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.notes = [PFObject]()
        self.tableView.addSubview(self.refreshControl)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.getMyNotes({
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (objects != nil) {
                self.notes = objects
                self.tableView.reloadData()
            }
        })
    }
    
    
    // MARK: UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("notesCell") as! NotesCell!
        if cell == nil {
            cell = NotesCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "notesCell")
        }
        
        cell.imageViewGag.image = nil
        cell.gag = nil
        cell.labelMessage.text = nil
        cell.labelCreatedAt.text = nil
        
        
        
        let note = self.notes[indexPath.row] as PFObject
        
        if let gag = note["gag"] {
            cell.gag = gag as? PFObject
            //cell.noteType = NoteType.Gag
        } else {
            cell.imageViewGag.image = nil
            //cell.noteType = NoteType.FriendRequest
        }
        
        cell.labelMessage.text = note["message"] as? String
        
        // Set labelCreatedAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let dateString = dateFormatter.stringFromDate(note.createdAt!)
        cell.labelCreatedAt.text = dateString
        
        
        // Mark notification as viewed and decrement badge
        if let viewed = note["viewed"] {
            if (viewed as! NSObject == false) {
                note["viewed"] = true
                note.saveEventually()
                
                let installation = PFInstallation.currentInstallation()
                if (installation.badge > 0) {
                    installation.badge--
                    installation.saveEventually()
                }
            }
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let note = self.notes[indexPath.row] as PFObject
        let gag = note["gag"] as! PFObject
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
