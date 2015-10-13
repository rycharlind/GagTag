//
//  CameraViewController.swift
//  GagTag
//
//  Created by Ryan on 10/11/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate {
    func previousButtonPressed(controller: CameraViewController, sender: UIButton)
    func forwardButtonPressed(controller: CameraViewController, sender: UIButton)
}


class CameraViewController: UIViewController {
    
    var delegate : CameraViewControllerDelegate?
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var buttonSwitch: UIButton!
    @IBOutlet weak var buttonFeed: UIButton!
    @IBOutlet weak var buttonTake: UIButton!
    @IBOutlet weak var buttonReel: UIButton!
    @IBOutlet weak var buttonFlash: UIButton!
    @IBOutlet weak var buttonSettings: UIButton!
    
    var captureSession : AVCaptureSession?
    var captureDevice : AVCaptureDevice?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    // MARK: Actions
    @IBAction func reel(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.previousButtonPressed(self, sender: sender as! UIButton)
        }
    }
    
    @IBAction func feed(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.forwardButtonPressed(self, sender: sender as! UIButton)
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
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
