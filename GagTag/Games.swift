//
//  ViewController.swift
//  GagTag
//
//  Created by Ryan on 9/1/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class GamesTableViewController: PFQueryTableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UsersViewControllerDelegate {
    
    // MARK: Properties
    
    // Mark: Actions
    @IBAction func logout(sender: UIBarButtonItem) {
        PFUser.logOut()
        showParseLogin()
    }
    
    @IBAction func add(sender: AnyObject) {
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        var currentUser = PFUser.currentUser()
        if currentUser == nil {
            showParseLogin()
        }
    }
    
    func showUsers() {
        var usersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("users") as! UsersViewController
        usersViewController.delegate = self
        self.presentViewController(usersViewController, animated: true, completion: nil)
    }
    
    func showCustomLogin() {
        var loginController = self.storyboard?.instantiateViewControllerWithIdentifier("loginNav") as! UINavigationController
        self.presentViewController(loginController, animated: true, completion: nil)
    }
    
    func showParseLogin() {
        
        // Not sure why I cannot assign the same UILabel to two different UIView's
        let labelLoginGagTag = UILabel()
        labelLoginGagTag.text = "GagTag"
        labelLoginGagTag.font = UIFont(name: labelLoginGagTag.font.fontName, size: 40)
        
        let labelSignUpGagTag = UILabel()
        labelSignUpGagTag.text = "GagTag"
        labelSignUpGagTag.font = UIFont(name: labelSignUpGagTag.font.fontName, size: 40)
        
        var parseLoginViewController = PFLogInViewController()
        parseLoginViewController.delegate = self
        parseLoginViewController.logInView?.logo = labelLoginGagTag
        
        var parseSignUpViewController = PFSignUpViewController()
        parseSignUpViewController.delegate = self
        parseSignUpViewController.signUpView?.logo = labelSignUpGagTag
        
        parseLoginViewController.signUpController = parseSignUpViewController
        
        self.presentViewController(parseLoginViewController, animated: true, completion: nil)
    }
    
    // MARK: PFLogInViewControllerDelegate
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        
        if (!username.isEmpty || !password.isEmpty) {
            return true
        } else {
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: UsersTableViewControllerDelegate
    func usersTableViewController(controller: UsersViewController, didSelectUsers users: [PFObject]) {
        println(users)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func queryForTable() -> PFQuery {
        var query = PFQuery(className: "GameUser")
        //query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.includeKey("game")
        return query
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        if let game = object?["game"] as? PFObject {
            cell.textLabel?.text = game.objectId
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let row = Int(indexPath.row)
        let gameUser = (objects?[row] as! PFObject)
        let game = gameUser.objectForKey("game") as! PFObject
        
        let gameViewController : GameViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("game") as! GameViewController
        gameViewController.game = game
        self.showViewController(gameViewController as GameViewController, sender: self)
        
    }




}

