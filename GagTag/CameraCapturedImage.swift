//
//  CameraCapturedImageViewController.swift
//  GagTag
//
//  Created by Ryan on 11/24/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse

protocol CameraCapturedImageDelegate {
    func buttonNextTouched(sender: AnyObject, image: UIImage, numberOfTags: Int)
}

class CameraCapturedImageViewController: UIViewController, UIPopoverPresentationControllerDelegate, NumberOfTagsDelegate, NotifyFriendsDelegate {
    
    // MARK: Properties
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonTags: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    var image: UIImage!
    var numberOfTags: Int = 5
    var delegate: CameraCapturedImageDelegate?

    // MARK: Actions
    @IBAction func buttonCloseTouched(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)  
    }
    
    @IBAction func buttonTagsTouched(sender: AnyObject) {
        self.showTagsAllowedSlider(sender as! UIButton)
    }
    
    @IBAction func buttonNextTouched(sender: AnyObject) {
        //delegate?.buttonNextTouched(sender, image: image, numberOfTags: numberOfTags)
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.showNotifyFriends()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        imageView.image = image
        self.progressView.progress = 0.0
    }
    
    func showTagsAllowedSlider(sender: UIButton) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("numberOfTags") as! NumberOfTagsViewController
        vc.modalPresentationStyle = .Popover
        vc.preferredContentSize = CGSizeMake(300, 100)
        vc.delegate = self
        
        let popoverViewController = vc.popoverPresentationController
        popoverViewController?.permittedArrowDirections = .Down
        popoverViewController?.delegate = self
        popoverViewController?.sourceView = self.view
        popoverViewController?.sourceRect = sender.frame
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showNotifyFriends() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("notifyFriends") as! NotifyFriendsViewController
        vc.delegate = self
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    // MARK: NumberOfTags
    func sliderValueChanged(slider: UISlider) {
        let sliderValue = Int(slider.value)
        self.numberOfTags = sliderValue
        let sliderValueString = String(sliderValue)
        self.buttonTags.setTitle(sliderValueString, forState: UIControlState.Normal)
    }
    
    // MARK: NotifyFriendsDelegate
    func sendGagWithSelectedFriends(friends: [PFUser]) {
        print("hello")
        ParseHelper.saveImage(image, numberOfTags: numberOfTags, friends: friends, completionBlock: {
            (succeeded: Bool, error: NSError?) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }, progressBlock: {
                (percentDone: Int32) -> Void in
                let progress = Float(percentDone) / 100.0
                print(progress)
                self.progressView.progress = progress
                print(percentDone, terminator: "")
        })
    }
    
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
