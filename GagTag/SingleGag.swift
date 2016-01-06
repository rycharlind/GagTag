//
//  SingleGagViewController.swift
//  GagTag
//
//  Created by Ryan on 12/13/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class SingleGagViewController: UIViewController {
    
    // View - Contains on the below hiding/showing all
    @IBOutlet weak var viewActions: UIView!
    
    // ImageView - Displays the image of the gag
    @IBOutlet weak var imageView: UIImageView!
    
    // Label - Displays the username of the user of the gag
    @IBOutlet weak var labelUsername: UILabel!
    
    // Label -  If winningTag is submitted, show winningTag
    //          else if chosenTag is submitted, show chosenTag
    //          else hide
    @IBOutlet weak var labelChosenOrWinningTag: UILabel!
    
    // Label - Displays all the users who have submitted tags
    @IBOutlet weak var labelUsers: UILabel!
    
    // Label - Dispaly the date and time of when the gag was created
    @IBOutlet weak var labelCreatedAt: UILabel!
    
    // Button - If user has not submitted a chosenTag and needs to
    //          OR user has not submitted a winningTag and needs to
    //          Then status is equal to tags
    //          Else status is equal to share
    @IBOutlet weak var buttonMainAction: UIButton!
    
    var gagId: String!
    var allowedNumberOfTags: Int!
    
    var gag: PFObject = PFObject(className: "Gag") {
        didSet {
            print("Set Gag")
            self.allowedNumberOfTags = self.gag["allowedNumberOfTags"] as! Int
            
            // Username
            let user = self.gag["user"]
            self.labelUsername.text = user["username"] as? String
            self.labelUsername.hidden = false
            
            // Date
            let dateFormatter = NSDateFormatter()
            //dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            let dateString = dateFormatter.stringFromDate(self.gag.createdAt!)
            self.labelCreatedAt.text = dateString
            self.labelCreatedAt.hidden = false
            
            // Check for winningTag
            if let winningTag = gag["winningTag"] {
                let value = winningTag["value"] as! String
                self.labelChosenOrWinningTag.text = "#\(value)"
                self.labelChosenOrWinningTag.hidden = false
                self.gagState = GagState.Complete
            }
            
            
            // Image
            let pfimage = gag["image"] as! PFFile
            pfimage.getDataInBackgroundWithBlock({
                (result, error) in
                if (result != nil) {
                    self.imageView.image = UIImage(data: result!)
                }
            })
            
            // GagUserTags
            ParseHelper.getAllGagUserTagObjectsForGag(self.gag, limit: self.allowedNumberOfTags, completionBlock: {
                (objects: [PFObject]?, error: NSError?) -> Void in
                self.gagUserTags = objects!
            })
        }
    }
    
    var gagUserTags: [PFObject] = [PFObject]() {
        didSet {
            print("Set GagUserTags")
            // Set labelUsersCount
            //self.labelUsersCount.text = "\(gagUserTags.count) of \(allowedNumberOfTags)"
            
            // Set labelUsers
            var text = ""
            for gagUserTag in gagUserTags {
                // Only show users have submitted a chosenTag
                if let _ = gagUserTag["chosenTag"] {
                    self.labelUsers.hidden = false
                    let user = gagUserTag["user"] as! PFUser
                    let username = user["username"] as! String
                    if text.isEmpty {
                        text = username
                    } else {
                        text += " \(username)"
                    }
                }
            }
            self.labelUsers.text = text
            
            
            // Check Tags
            if (gagUserTags.count == allowedNumberOfTags) {
                if let _ = gag["winningTag"] {
                    self.gagState = GagState.Complete
                    ParseHelper.getWinningUserForGag(gag, completionBlock: {
                        (user: PFUser?) -> Void in
                        if (user != nil) {
                            let username = user!["username"] as! String
                            self.labelUsers.text = username
                            self.labelUsers.hidden = false
                        }
                    })
                } else {
                    let user = gag["user"] as! PFUser
                    if (user.objectId == PFUser.currentUser()!.objectId) {
                        self.gagState = GagState.ChoseWinningTag
                    } else {
                        //self.gagState = GagState.Waiting
                        for gagUserTag in gagUserTags {
                            let user = gagUserTag["user"] as! PFUser
                            if (user.objectId == PFUser.currentUser()!.objectId) {
                                if let chosenTag = gagUserTag["chosenTag"] {
                                    let value = chosenTag["value"] as! String
                                    self.labelChosenOrWinningTag.text = "#\(value)"
                                    self.labelChosenOrWinningTag.hidden = false
                                    self.gagState = GagState.Waiting
                                }
                            }
                        }
                    }
                }
            } else {
                
                let user = gag["user"] as! PFUser
                if (user.objectId == PFUser.currentUser()!.objectId) {
                    self.gagState = GagState.Waiting
                } else {
                    self.gagState = GagState.ChoseDealtTag
                    for gagUserTag in gagUserTags {
                        let user = gagUserTag["user"] as! PFUser
                        if (user.objectId == PFUser.currentUser()!.objectId) {
                            if let chosenTag = gagUserTag["chosenTag"] {
                                let value = chosenTag["value"] as! String
                                self.labelChosenOrWinningTag.text = "#\(value)"
                                self.labelChosenOrWinningTag.hidden = false
                                self.gagState = GagState.Waiting
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    var gagState: GagState = .Waiting {
        didSet {
            switch(gagState) {
            case .ChoseDealtTag:
                print("ChoseDealtTag")
                self.buttonMainAction.hidden = false
            case .ChoseWinningTag:
                print("ChoseWinningTag")
                self.buttonMainAction.hidden = false
            case .Waiting:
                print("Waiting")
                self.buttonMainAction.hidden = true
                self.labelChosenOrWinningTag.backgroundColor = UIColor.MKColor.Blue
            case .Complete:
                print("Complete")
                self.buttonMainAction.hidden = true
                self.labelChosenOrWinningTag.backgroundColor = UIColor.MKColor.Green
            case .None:
                print("None")
            }
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)  
    }
    
    @IBAction func showActionsView(sender: AnyObject) {
        self.viewActions.hidden = false
    }
    
    @IBAction func hideActionView(sender: AnyObject) {
        self.viewActions.hidden = true
    }
    
    @IBAction func buttonMainActionTouched(sender: AnyObject) {
        print("Main Action Touched")
        switch(gagState) {
        case .ChoseDealtTag:
            print("ChoseDealtTag")
            self.showDealtTagsForGag(self.gag)
        case .ChoseWinningTag:
            print("ChoseWinningTag")
            self.showChosenTagsForGag(self.gag)
        case .Waiting:
            print("Waiting")
            
        case .Complete:
            print("Complete")
            
        case .None:
            print("None")
        }
    }
    
    func showDealtTagsForGag(gag: PFObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("dealtTags") as! DealtTagsViewController
        vc.gag = gag
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showChosenTagsForGag(gag: PFObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("chosenTags") as! ChosenTagsViewController
        vc.gag = gag
        self.presentViewController(vc, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.labelChosenOrWinningTag.hidden = true
        self.labelCreatedAt.hidden = true
        self.labelUsername.hidden = true
        self.labelUsers.hidden = true
        self.gagState = .Waiting
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        ParseHelper.getGagWithId(self.gagId, completionBlock: {
            (object: PFObject?, error: NSError?) -> Void in
            self.gag = object!
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
