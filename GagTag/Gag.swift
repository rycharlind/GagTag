//
//  GameViewController.swift
//  GagTag
//
//  Created by Ryan on 9/7/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

class GagViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UsersViewControllerDelegate, TagsViewControllerDelegate {
    
    // MARK:  Properties
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var barButtonPhoto: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    var gag : PFObject!
    var gagUserTag : PFObject!
    var gagImage : UIImage!
    var newImage : UIImage!
    var imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.progressView.hidden = true
        self.imagePicker.delegate = self
        self.imageView.contentMode = .ScaleAspectFit
    
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if (self.gag != nil) {
            println(self.gag)
            self.updateUI()
            queryGagImage()
            queryGagUserTag()
        }
        
    }
    
    func updateUI() {
        
        if let chosenTag = self.gagUserTag?["chosenTag"] as? PFObject {
            self.labelTag?.text = chosenTag["value"] as? String
            self.labelTag?.hidden = false
        }
        
        if let winningTag = self.gag["winningTag"] as? PFObject {
            self.labelTag?.text = winningTag["value"] as? String
            self.labelTag?.hidden = false
        }
        
        if (self.newImage != nil) {
            self.imageView.image = self.newImage
        }
        
        if (self.gagImage != nil) {
            self.imageView.image = self.gagImage
        }
        
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
    
    @IBAction func actionTags(sender: AnyObject) {
        showTags()
    }
    
    func queryGagUserTag() {
        var query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.includeKey("chosenTag")
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                println("queryGagUserTag:  The getFirstObject request failed.")
            } else {
                // The find succeeded.
                println("queryGagUserTag:  Found first object.")
                self.gagUserTag = object
                self.updateUI()
            }
        })
    }
    
    func queryGagImage() {
        var queryGag = PFQuery(className: "Gag")
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
                println(error)
            }
        })
        
    }
    
    func showTags() {
        var tagsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tags") as! TagsViewController
        tagsViewController.gag = self.gag
        tagsViewController.delegate = self
        self.presentViewController(tagsViewController, animated: true, completion: nil)
    }
    
    
    func sendChosenTag(tag : PFObject) {
        var query = PFQuery(className: "GagUserTag")
        query.whereKey("gag", equalTo: self.gag)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.getFirstObjectInBackgroundWithBlock({
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                println("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                println("Found first object.")
                object?.setObject(tag, forKey: "chosenTag")
                object?.saveInBackgroundWithBlock({
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                    } else {
                        // There was a problem, check error.description
                    }
                })
                
            }
        })
    }
    
    func sendWinningTag(tag : PFObject) {
        self.gag.setObject(tag, forKey: "winningTag")
        self.gag.saveInBackgroundWithBlock({
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                println("Winning Tag:  Success")
            } else {
                // There was a problem, check error.description
                println("Winning Tag:  Failed")
            }
        })
        
    }
    
    func sendPhoto(users: [String:PFObject]) {
        
        if (self.newImage != nil) {
            
            let imageData = UIImagePNGRepresentation(self.newImage)
            let imageFile = PFFile(name:"photo.png", data:imageData)
            self.progressView.hidden = false
            self.imageView.alpha = CGFloat(0.25)
            imageFile.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError?) -> Void in
                // Handle success or failure here ...
                if (succeeded) {
                    var gag = PFObject(className:"Gag")
                    gag["user"] = PFUser.currentUser()
                    var relation = gag.relationForKey("friends")
                    
                    for (key, value) in users {
                        relation.addObject(value)
                    }
                    
                    gag["image"] = imageFile
                    gag.saveInBackgroundWithBlock({
                        (succeeded: Bool, error: NSError?) -> Void in
                        self.progressView.hidden = true
                        self.imageView.alpha = CGFloat(1)
                        if (succeeded) {
                            println("Done")
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            println(error)
                        }
                    })
                }
                }, progressBlock: {
                    (percentDone: Int32) -> Void in
                    // Update your progress spinner here. percentDone will be between 0 and 100.
                    print(percentDone)
                    self.progressView.progress = Float(percentDone) / 100
            })
            
        } else {
            println("No image chosen")
        }
        

    }
    
    func showUsers() {
        var usersViewController = self.storyboard?.instantiateViewControllerWithIdentifier("users") as! UsersViewController
        usersViewController.delegate = self
        self.presentViewController(usersViewController, animated: true, completion: nil)
    }
    
    // MARK:  UIImageIckerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
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
        println(users)
        self.sendPhoto(users)
    }
    
    // MARK: TagsViewControllerDelegate
    func tagsViewController(controller: TagsViewController, didSelectTag tag: PFObject) {
        //sendChosenTag(tag)
        sendWinningTag(tag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
