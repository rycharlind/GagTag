//
//  CameraViewController.swift
//  GagTag
//
//  Created by Ryan on 10/11/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

extension UIImage {
    var highestQualityJPEGNSData:NSData { return UIImageJPEGRepresentation(self, 1.0)! }
    var highQualityJPEGNSData:NSData    { return UIImageJPEGRepresentation(self, 0.75)!}
    var mediumQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.5)! }
    var lowQualityJPEGNSData:NSData     { return UIImageJPEGRepresentation(self, 0.25)!}
    var lowestQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.0)! }
}

enum CameraViewStatus {
    case Running, Preview
}

class CameraViewController: UIViewController {
    
    // MARK: Properites
    var mainNavDelegate: MainNavDelegate?
    var allowedNumberOfTags: Int = 5
    
    let cameraManager = CameraManager()
    
    @IBOutlet weak var buttonToggleCamera: UIButton!
    @IBOutlet weak var buttonToggleFlash: UIButton!
    @IBOutlet weak var buttonFeed: UIButton!
    @IBOutlet weak var buttonTake: UIButton!
    @IBOutlet weak var buttonReel: UIButton!
    @IBOutlet weak var buttonSettings: UIButton!
    
    // Camera Properties
    @IBOutlet weak var previewView: UIView!
    var captureSession : AVCaptureSession?
    var captureDevice : AVCaptureDevice?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // MARK: Actions
    @IBAction func reel(sender: AnyObject) {
        if let delegate = self.mainNavDelegate {
            delegate.goToController(0, direction: .Reverse, animated: true)
        }
    }
    
    @IBAction func feed(sender: AnyObject) {
        if let delegate = self.mainNavDelegate {
            delegate.goToController(2, direction: .Forward, animated: true)
        }
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        cameraManager.capturePictureWithCompletition({ (image, error) -> Void in
            self.showCameraCapturedImage(image!)
        })
    }
    
    func showNotifyFriends() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("notifyFriends") as! NotifyFriendsViewController
        //vc.delegate = self
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    @IBAction func settings(sender: AnyObject) {
        //self.showSettings()
        self.showSettingsNav()
    }
    
    @IBAction func buttonToggleCameraTouched(sender: AnyObject) {
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.Front ? CameraDevice.Back : CameraDevice.Front
        switch (cameraManager.cameraDevice) {
        case .Front:
            sender.setTitle(GoogleIcon.ea43, forState: .Normal)
        case .Back:
            sender.setTitle(GoogleIcon.ea41, forState: .Normal)
        }
    }
    
    @IBAction func buttonToggleFlashTouch(sender: AnyObject) {
        switch (cameraManager.changeFlashMode()) {
        case .Off:
            sender.setTitle(GoogleIcon.eaa9, forState: .Normal)
        case .On:
            sender.setTitle(GoogleIcon.eaab, forState: .Normal)
        case .Auto:
            sender.setTitle(GoogleIcon.eaa7, forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Take Button
        self.buttonTake.layer.cornerRadius = 0.5 * self.buttonTake.bounds.width
        self.buttonTake.layer.masksToBounds = true
        self.buttonTake.layer.borderWidth = 2.0
        self.buttonTake.layer.borderColor = UIColor.blackColor().CGColor
        
        // Configure Notifications button
        self.buttonReel.layer.cornerRadius = 5
        self.buttonReel.layer.masksToBounds = true
        
        cameraManager.shouldRespondToOrientationChanges = false
        addCameraToView()
        
        if !cameraManager.hasFlash {
            buttonToggleFlash.enabled = false
            buttonToggleFlash.setTitle(GoogleIcon.eaa9, forState: .Normal)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.hideNotesViewForButton(self.buttonReel)
        ParseHelper.getMyNewNotesCount({
            (count: Int32, error: NSError?) -> Void in
            if error == nil {
                print("Notes Count: \(count)")
                if (count > 0) {
                    self.showNotesViewForButton(self.buttonReel, badgeNumber: count)
                    //self.buttonReel.setTitle("", forState: .Normal)
                }
            }
        })
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    
    private func addCameraToView() {
        cameraManager.addPreviewLayerToView(previewView, newCameraOutputMode: CameraOutputMode.StillImage)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in  }))
            
            self?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: Show Views
    func showSettings() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("settings") as! SettingsViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showSettingsNav() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("settingsNav") as! SettingsNavigationController
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showCameraCapturedImage(image: UIImage) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("cameraCapturedView") as! CameraCapturedImageViewController
        vc.image = image
        //vc.delegate = self
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    func showNotesViewForButton(button: UIButton, badgeNumber: Int32) {
        button.hidden = true
        button.backgroundColor = UIColor.MKColor.DeepOrange
        button.titleLabel?.font = UIFont(name: "Arial", size: 20.0)
        button.setTitle(String(badgeNumber), forState: .Normal)
        button.hidden = false
    }
    
    func hideNotesViewForButton(button: UIButton) {
        button.hidden = true
        button.backgroundColor = UIColor.clearColor()
        button.titleLabel?.font = UIFont(name: "googleicon", size: 28.0)
        button.setTitle(GoogleIcon.ebe4, forState: .Normal)
        button.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
