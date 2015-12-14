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
    
    enum GagStatus {
        case WinningTagChosen
        case IChoseTag
        case AllDealtTagsChosen
        case None
    }
    
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
    
    // Label - Displays all the tags submitted by other players on the gag
    @IBOutlet weak var labelTags: UILabel!
    
    // Label - Dispaly the date and time of when the gag was created
    @IBOutlet weak var labelCreatedAt: UILabel!
    
    // Button - If user has not submitted a chosenTag and needs to
    //          OR user has not submitted a winningTag and needs to
    //          Then status is equal to tags
    //          Else status is equal to share
    @IBOutlet weak var buttonMainAction: UIButton!
    
    var gagId: String!
    
    var gag: PFObject = PFObject(className: "Gag") {
        didSet {
            print("Set Gag")
            
            // Username
            let user = self.gag["user"]
            self.labelUsername.text = user["username"] as? String
            self.labelUsername.hidden = false
            
            // Date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm"
            let dateString = dateFormatter.stringFromDate(self.gag.createdAt!)
            self.labelCreatedAt.text = dateString
            self.labelCreatedAt.hidden = false
            
            
            // Image
            let pfimage = gag["image"] as! PFFile
            pfimage.getDataInBackgroundWithBlock({
                (result, error) in
                if (result != nil) {
                    self.imageView.image = UIImage(data: result!)
                }
            })
            
            // GagUserTags
            ParseHelper.getAllGagUserTagObjectsForGag(self.gag, completionBlock: {
                (objects: [PFObject]?, error: NSError?) -> Void in
                self.gagUserTags = objects!
            })
        }
    }
    
    var gagUserTags: [PFObject] = [PFObject]() {
        didSet {
            print("Set GagUserTags")
            self.populateLabelUsers()
            self.populateLabelTags()
            self.populateChosenOrWinnigTag()
        }
    }
    
    var gagStatus: GagStatus = .None {
        didSet {
            switch gagStatus {
            case .AllDealtTagsChosen:
                print("All Dealt Tags Chosen")
                self.buttonMainAction.hidden = false
            case .WinningTagChosen:
                print("Winning Tag Chosen")
                self.buttonMainAction.hidden = true
            case .IChoseTag:
                print("I Chose Tag")
                self.buttonMainAction.hidden = true
            case .None:
                print("None")
                self.buttonMainAction.hidden = false
            }
        }
    }
    
    func populateLabelUsers() {
        var text = ""
        for gagUserTag in self.gagUserTags {
            // Only show users have submitted a chosenTag
            if let chosenTag = gagUserTag["chosenTag"] {
                let user = gagUserTag["user"] as! PFUser
                let username = user["username"] as! String
                if text.isEmpty {
                    text = username
                } else {
                    text += " \(username)"
                }
                self.labelUsers.hidden = false
            }
        }
        self.labelUsers.text = text
    }
    
    func populateLabelTags() {
        var text = ""
        for gagUserTag in self.gagUserTags {
            if let chosenTag = gagUserTag["chosenTag"] {
                let value = chosenTag["value"] as! String
                if text.isEmpty {
                    text = " #\(value)"
                } else {
                    text += " #\(value)"
                }
                self.labelTags.hidden = false
            }
        }
        self.labelTags.text = text
    }
    
    func populateChosenOrWinnigTag() {
        
        if let winningTag = self.gag["winningTag"] {
            let value = winningTag["value"] as! String
            self.labelChosenOrWinningTag.text = " #\(value)"
            self.labelChosenOrWinningTag.hidden = false
            self.gagStatus = .WinningTagChosen
        } else {
            for gagUserTag in self.gagUserTags {
                if let chosenTag = gagUserTag["chosenTag"] {
                    let user = gagUserTag["user"]
                    if (user.objectId == PFUser.currentUser()!.objectId) {
                        let value = chosenTag["value"] as! String
                        self.labelChosenOrWinningTag.text = " #\(value)"
                        self.labelChosenOrWinningTag.hidden = false
                        self.gagStatus = .IChoseTag
                    }
                }
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
        switch gagStatus {
        case .AllDealtTagsChosen:
            print("All Dealt Tags Chosen")
            self.showChosenTagsForGag(self.gag)
        case .WinningTagChosen:
            print("Winning Tag Chosen")
            
        case .IChoseTag:
            print("I Chose Tag")
            
        case .None:
            print("None")
            self.showDealtTagsForGag(self.gag)
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
        self.labelTags.hidden = true
        self.labelUsername.hidden = true
        self.labelUsers.hidden = true
        self.gagStatus = .None
    
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
