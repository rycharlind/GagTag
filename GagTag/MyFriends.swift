//
//  MyFriendsViewController.swift
//  GagTag
//
//  Created by Ryan on 10/5/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class MyFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var users = [PFUser]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ParseHelper.getFriendsForUser(PFUser.currentUser()!, completionBlock: self.updateList)
    }
    
    func updateList(objects: [PFObject]?, error: NSError?) {
        print(objects)
        self.users = objects as! [PFUser]
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("myFriendsCell") as! MyFriendsCell!
        if cell == nil {
            cell = MyFriendsCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "myFriendsCell")
        }
        
        let user = self.users[indexPath.row] as PFUser
        cell?.labelUsername?.text = user.username
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
