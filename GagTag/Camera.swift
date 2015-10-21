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
    
    var mainNavDelegate: MainNavDelegate?
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var cameraRunningView: UIView!
    @IBOutlet weak var buttonSwitch: UIButton!
    @IBOutlet weak var buttonFeed: UIButton!
    @IBOutlet weak var buttonTake: UIButton!
    @IBOutlet weak var buttonReel: UIButton!
    @IBOutlet weak var buttonFlash: UIButton!
    @IBOutlet weak var buttonSettings: UIButton!
    
    @IBOutlet weak var cameraCapturedView: UIView!
    
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
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    self.imageView.image = image
                    
                    self.updateUI(CameraViewStatus.Preview)
                    
                }
            })
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        self.updateUI(CameraViewStatus.Running)
    }
    
    @IBAction func next(sender: AnyObject) {
        self.saveImage()
    }
    
    @IBAction func settings(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("settings") as! SettingsViewController
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }
    

    func updateUI(cameraStatus: CameraViewStatus) {
        switch (cameraStatus) {
        case CameraViewStatus.Running:
            print("UpdateUI: Running")
            self.cameraRunningView.hidden = false
            self.cameraCapturedView.hidden = true
            self.previewView.hidden = false
            self.imageView.hidden = true
        case CameraViewStatus.Preview:
            print("UpdateUI: Preview")
            self.cameraRunningView.hidden = true
            self.cameraCapturedView.hidden = false
            self.previewView.hidden = true
            self.imageView.hidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI(CameraViewStatus.Running)

        // Do any additional setup after loading the view.
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
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
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewLayer!.frame = previewView.bounds
                previewView.layer.addSublayer(previewLayer!)
                
                captureSession!.startRunning()
            }
        }
        
    }
    
    func saveImage() {
        
        if (self.imageView.image != nil) {
            
            let alert = UIAlertController(title: "Sending", message: "0", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            let imageData = self.imageView.image!.lowQualityJPEGNSData
            let imageFile = PFFile(name:"photo.png", data:imageData)
            imageFile!.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError?) -> Void in
                // Handle success or failure here ...
                if (succeeded) {
                    let gag = PFObject(className:"Gag")
                    gag["user"] = PFUser.currentUser()
                    
                    gag["image"] = imageFile
                    gag.saveInBackgroundWithBlock({
                        (succeeded: Bool, error: NSError?) -> Void in
                        
                        if (succeeded) {
                            print("Done")
                            alert.message = "Done"
                        } else {
                            print(error)
                        }
                    })
                }
                }, progressBlock: {
                    (percentDone: Int32) -> Void in
                    // Update your progress spinner here. percentDone will be between 0 and 100.
                    print(percentDone, terminator: "")
                    //self.progressView.progress = Float(percentDone) / 100
                    alert.message = String(percentDone) + "%"
            })
            
        } else {
            print("No image captured")
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
