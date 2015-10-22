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

class GagReelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    var gags : [PFObject]!
    var gagUserTag : PFObject!
    var mainNavDelegate : MainNavDelegate?
    @IBOutlet weak var tableView: UITableView!
    
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
        
        // Congifure Nib or custom cell
        let nib = UINib(nibName: "GagFeedCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "gagFeedCell")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        ParseHelper.getMyGags(self.newFunction)
    }
    
    func newFunction(objects: [PFObject]?, error: NSError?) {
        if (error == nil) {
            self.gags = objects
            self.tableView.reloadData()
        } else {
            print("Error: \(error!) \(error!.userInfo)")
        }
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
        
        let gag = self.gags[indexPath.row] as PFObject
        
        
        if let tag = gag["winningTag"] as? PFObject {
            let value = tag["value"] as! String
            cell?.labelTag.text = value
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
