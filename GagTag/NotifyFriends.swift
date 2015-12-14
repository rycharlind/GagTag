//
//  NotifyFriendsViewController.swift
//  GagTag
//
//  Created by Ryan on 12/11/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol NotifyFriendsDelegate {
    func sendGagWithSelectedFriends(friends: [PFUser])
}

class NotifyFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NotifyFriendsCellDelegate, UISearchBarDelegate {
    
    // MARK: Properties
    // stores all the users that match the current search query
    var userDict: [String:[PFUser]]!
    var sectionTitles: [String]!
    @IBOutlet weak var barButtonSend: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var delegate: NotifyFriendsDelegate?
    
    var selectedFriends: [PFUser] = [PFUser]() {
        didSet {
            if (self.selectedFriends.count > 0) {
                self.barButtonSend.enabled = true
            } else {
                self.barButtonSend.enabled = false
            }
        }
    }
    
    // MARK: Actions
    @IBAction func send(sender: AnyObject) {
        self.delegate?.sendGagWithSelectedFriends(self.selectedFriends)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // this view can be in two different states
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    // the current parse query
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            oldValue?.cancel()
        }
    }
    
    // whenever the state changes, perform one of the two queries and update the list
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                query = ParseHelper.getFriendsDictionaryForUser(PFUser.currentUser()!, completionBlock: {
                    (userDict: [String: [PFUser]]) -> Void in
                    self.userDict = userDict
                    self.updateList()
                })
                
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchFriendsDictionaryForUser(searchText, user: PFUser.currentUser()!, completionBlock: {
                    (userDict: [String: [PFUser]]) -> Void in
                    self.userDict = userDict
                    self.updateList()
                })
            }
        }
    }
    
    func updateList() {
        self.sectionTitles = [String]()
        for (key, value) in userDict {
            self.sectionTitles.append(key)
        }
        self.sectionTitles = self.sectionTitles.sort(<)
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.users = [PFUser]()
        self.userDict = [String:[PFUser]]()
        self.sectionTitles = [String]()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        state = .DefaultMode
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = self.sectionTitles[section]
        return title
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.sectionTitles
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = self.sectionTitles[section]
        let sectionUsers = self.userDict[sectionTitle]
        return sectionUsers!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("notifyFriendsCell") as! NotifyFriendsCell!
        if cell == nil {
            cell = NotifyFriendsCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "notifyFriendsCell")
        }
        
        let sectionTitle = self.sectionTitles[indexPath.section]
        let sectionUsers = self.userDict[sectionTitle]
        let user = sectionUsers![indexPath.row]
        
        cell.labelUsername.text = user["username"] as? String
        cell.user = user
        
        
        cell.delegate = self
        cell.rippleLayerColor = UIColor.MKColor.LightBlue
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotifyFriendsCell
        
        if (cell.friendSelected == true) {
            cell.friendSelected = false
        } else {
            cell.friendSelected = true
        }
    }
    
    
    // MARK: SearchBarDelegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ParseHelper.searchFriendsDictionaryForUser(searchText, user: PFUser.currentUser()!, completionBlock: {
            (userDict: [String: [PFUser]]) -> Void in
            self.userDict = userDict
            self.updateList()
        })
    }
    
    
    // MARK: NotifyFriendsCellDelegate
    func didSelectFriend(cell: NotifyFriendsCell) {
        let indexPath = self.tableView.indexPathForCell(cell)! as NSIndexPath
        let sectionTitle = self.sectionTitles[indexPath.section]
        let sectionUsers = self.userDict[sectionTitle]
        let user = sectionUsers![indexPath.row]
        self.selectedFriends.append(user)
        print(self.selectedFriends)
    }
    
    func didDeselectFriend(cell: NotifyFriendsCell) {
        let index = self.selectedFriends.indexOf(cell.user!)
        self.selectedFriends.removeAtIndex(index!)
        print(self.selectedFriends)
    }
    

}
