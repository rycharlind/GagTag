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

class CameraViewController: UIViewController, CameraCapturedImageDelegate {
    
    // MARK: Properites
    var mainNavDelegate: MainNavDelegate?
    var allowedNumberOfTags: Int = 5
    
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
        //self.showNotifyFriends()
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    
                    var imageOrientation = UIImageOrientation.Right
                    if (self.captureDevice!.position == AVCaptureDevicePosition.Front) {
                        imageOrientation = UIImageOrientation.LeftMirrored
                    }
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: imageOrientation)
                    
                    
                    
                    self.showCameraCapturedImage(image)
                }
            
            
            })
        }
        
        
    }
    
    func showNotifyFriends() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("notifyFriends") as! NotifyFriendsViewController
        //vc.delegate = self
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    @IBAction func settings(sender: AnyObject) {
        self.showSettings()
    }
    
    @IBAction func buttonToggleCameraTouched(sender: AnyObject) {
        
        captureSession?.beginConfiguration()
        
        let currentCamerInput: AVCaptureInput = captureSession?.inputs[0] as! AVCaptureInput
        captureSession?.removeInput(currentCamerInput)
        
        let newCamera: AVCaptureDevice?
        if (captureDevice!.position == AVCaptureDevicePosition.Back) {
            print("Setting new camera with Front")
            newCamera = self.cameraWithPosition(AVCaptureDevicePosition.Front)
            buttonToggleCamera.setTitle(GoogleIcon.ea43, forState: .Normal)
        } else {
            print("Setting new camera with Back")
            newCamera = self.cameraWithPosition(AVCaptureDevicePosition.Back)
            buttonToggleCamera.setTitle(GoogleIcon.ea41, forState: .Normal)
        }
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: newCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
    
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
        }
        
        captureDevice! = newCamera!
        
        captureSession?.commitConfiguration()
        
    }
    
    @IBAction func buttonToggleFlashTouch(sender: AnyObject) {
        
        let mode = captureDevice?.flashMode
        do {
            try captureDevice?.lockForConfiguration()
            
            if (mode == AVCaptureFlashMode.Off) {
                captureDevice?.flashMode = AVCaptureFlashMode.On
                buttonToggleFlash.setTitle(GoogleIcon.eaab, forState: .Normal)
            } else {
                captureDevice?.flashMode = AVCaptureFlashMode.Off
                buttonToggleFlash.setTitle(GoogleIcon.eaa9, forState: .Normal)
            }
            
            captureDevice?.unlockForConfiguration()
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if(device.position == position){
                return device as! AVCaptureDevice
            }
        }
        return AVCaptureDevice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        // Configure Take Button
        self.buttonTake.layer.cornerRadius = 0.5 * self.buttonTake.bounds.width
        self.buttonTake.layer.masksToBounds = true
        self.buttonTake.layer.borderWidth = 2.0
        self.buttonTake.layer.borderColor = UIColor.blackColor().CGColor

        // Do any additional setup after loading the view.
        
        
        // Camera Set
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if captureSession!.canAddOutput(stillImageOutput) {
                
                captureSession!.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResize
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        previewLayer!.frame = previewView.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: CameraCapturedViewDelegate
    func buttonNextTouched(sender: AnyObject, image: UIImage, numberOfTags: Int) {
        //self.saveImage(image, numberOfTags: numberOfTags)
    }
    
    func showSettings() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("settings") as! SettingsViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showCameraCapturedImage(image: UIImage) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("cameraCapturedView") as! CameraCapturedImageViewController
        vc.image = image
        vc.delegate = self
        self.presentViewController(vc, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
