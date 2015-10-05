//
//  FriendsMenuViewController.swift
//  GagTag
//
//  Created by Ryan on 10/4/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit

class FriendsMenuViewController: UITableViewController {

    @IBAction func done(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.row) {
        case 0:
            self.showFindFriends()
        case 1:
            self.showFriendRequests()
        default:
            self.showFindFriends()
        }
        
    }
    
    func showFindFriends() {
        var findFreindsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("findFriends") as! FindFriendsViewController
        findFreindsViewController.navigationItem.title = "Find Friends"
        //findFreindsViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.pushViewController(findFreindsViewController, animated: true)
    }
    
    func showFriendRequests() {
        var friendRequestsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("friendRequests") as! FriendRequestsViewController
        self.navigationController?.pushViewController(friendRequestsViewController, animated: true)
    }


    

}
