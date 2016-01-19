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
        
        self.navigationController?.navigationItem.title = "Friends"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showFindFriends() {
        let findFreindsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("findFriends") as! FindFriendsViewController
        findFreindsViewController.navigationItem.title = "Find Friends"
        //findFreindsViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.pushViewController(findFreindsViewController, animated: true)
    }
    
    func showFriendRequests() {
        let friendRequestsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("friendRequests") as! FriendRequestsViewController
        self.navigationController?.pushViewController(friendRequestsViewController, animated: true)
    }
    
    func showMyFriends() {
        let myFriendsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("myFriends") as! MyFriendsViewController
        self.navigationController?.pushViewController(myFriendsViewController, animated: true)
    }

}
