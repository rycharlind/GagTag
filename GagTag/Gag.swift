//
//  GameViewController.swift
//  GagTag
//
//  Created by Ryan on 9/7/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class GagViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UsersViewControllerDelegate, DealtTagsViewControllerDelegate {
    
    // MARK:  Properties
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var barButtonSend: UIBarButtonItem!
    @IBOutlet weak var barButtonTags: UIBarButtonItem!
    @IBOutlet weak var barButtonChoose: UIBarButtonItem!
    @IBOutlet weak var barButtonCamera: UIBarButtonItem!
    var gag : PFObject!
    var gagUserTag : PFObject!
    var gagImage : UIImage!
    var newImage : UIImage!
    var imagePicker = UIImagePickerController()
    
    @IBAction func actionUsers(sender: AnyObject) {
        showGagUsers()
    }
    
    // MARK: Actions
    @IBAction func actionSend(sender: AnyObject) {
        self.showUsers()
    }
    
    @IBAction func actionChoose(sender: AnyObject) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func actionCamera(sender: AnyObject) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func actionTags(sender: AnyObject) {
        if let user = self.gag["user"] as? PFObject {
            // If this is the current user's gag then show chosen tags
            if (user.objectId == PFUser.currentUser()?.objectId) {
            } else { // Else show the dealt tags
                self.showDealtTags()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imagePicker.delegate = self
        self.imageView.contentMode = .ScaleAspectFit
    
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        if (self.gag != nil) {
            print(self.gag)
            queryGagImage()
            queryGagUserTag()
        }
        self.updateUI()
        
    }
    
    func updateUI() {
        
        // TAG BUTTON
        // Check if there is a winning tag
        if let winningTag = self.gag?["winningTag"] as? PFObject {
            print("winningTag: not nil")
            self.labelTag?.text = "#" + (winningTag["value"] as? String)!
            self.labelTag?.hidden = false
            self.barButtonTags.enabled = false
        } else {
            print("winningTag: nil")
            // Check if there is a chosen tag
            if let chosenTag = self.gagUserTag?["chosenTag"] as? PFObject {
                print("chosenTag - not nil")
                self.labelTag?.text = "#" + (chosenTag["value"] as? String)!
                self.labelTag?.hidden = false
                self.barButtonTags.enabled = false
            } else {
                print("chosenTag - nil")
                self.barButtonTags.enabled = true
            }
        }
        
        // SEND BUTTON
        // Cehck newImage
        if (self.newImage != nil) {
            print("newImage: not nil")
            self.barButtonSend.enabled = true
            self.imageView.image = self.newImage
        } else {
            print("newImage: nil")
            self.barButtonSend.enabled = false
        }
        
        // SEND / CHOOSE BUTTON
        // If there is already an image then display it
        if (self.gagImage != nil) {
            print("gagImage: not nil")
            self.imageView.image = self.gagImage
            self.barButtonSend.enabled = false
            self.barButtonChoose.enabled = false
            self.barButtonCamera.enabled = false
        } else {
            print("gagImage: nil")
            self.barButtonSend.enabled = true
            self.barButtonChoose.enabled = true
            self.barButtonCamera.enabled = true
            self.barButtonTags.enabled = false
        }
        
    }
    
    // MARK:  Show Views
    func showGagUsers() {
        let gagUsersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gagUsers") as! GagUsersViewController
        gagUsersViewController.gag = self.gag
        self.presentViewController(gagUsersViewController, animated: true, completion: nil)
    }
    
    func showDealtTags() {
        let dealtTagsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("dealtTags") as! DealtTagsViewController
        dealtTagsViewController.gag = self.gag
        dealtTagsViewController.delegate = self;
        self.presentViewController(dealtTagsViewController, animated: true, completion: nil)
    }
    
    func showUsers() {
        let usersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("users") as! UsersViewController
        usersViewController.delegate = self
        self.presentViewController(usersViewController, animated: true, completion: nil)
    }

    
    // MARK: Query Data
    func queryGagUserTag() {
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.includeKey("chosenTag")
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("queryGagUserTag:  The getFirstObject request failed.")
            } else {
                // The find succeeded.
                print("queryGagUserTag:  Found first object.")
                self.gagUserTag = object
                self.updateUI()
            }
        })
    }
    
    func queryGag() {
        let queryGag = PFQuery(className: "Gag")
        queryGag.getObjectInBackgroundWithId(self.gag.objectId!, block: {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                print("Successfully retrieved the object.")
                self.gag = object
            }
        })
    }
    
    func queryGagImage() {
        let queryGag = PFQuery(className: "Gag")
        queryGag.getObjectInBackgroundWithId(self.gag.objectId!, block: {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil && object != nil {
                
                if let pfimage = object?["image"] as? PFFile {
                    
                    pfimage.getDataInBackgroundWithBlock({
                        (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                self.gagImage = UIImage(data:imageData)
                                self.updateUI()
                            }
                        }
                    })
                    
                }
                
            } else {
                print(error)
            }
        })
    }
    
    
    // MARK:  Send Data
    func sendWinningTag(tag : PFObject) {
        self.gag.setObject(tag, forKey: "winningTag")
        self.gag.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("Winning Tag:  Success")
                self.queryGag()
            } else {
                // There was a problem, check error.description
                print("Winning Tag:  Failed")
            }
        })
        
    }
    
    func sendChosenTag(tag : PFObject) {
        print("sendChosenTag")
        let query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                object?.setObject(tag, forKey: "chosenTag")
                object?.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        self.queryGagUserTag()
                    } else {
                        // There was a problem, check error.description
                    }
                })
                
            }
        })
    }
    
    
    // MARK:  UIImageIckerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("didFinishPickingImage")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.newImage = pickedImage
            self.updateUI()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UsersTableViewControllerDelegate
    func usersTableViewController(controller: UsersViewController, didSelectUsers users: [String:PFObject]) {
        print(users)
        //self.sendPhoto(users)
    }
    
    // MARK: DealtTagsViewController
    func dealtTagsViewController(controller: DealtTagsViewController, didSelectTag tag: PFObject) {
        self.sendChosenTag(tag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
