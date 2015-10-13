//
//  MainViewController.swift
//  GagTag
//
//  Created by Ryan on 10/12/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIPageViewControllerDataSource, CameraViewControllerDelegate {
    
    var pageViewController : UIPageViewController!
    var viewControllers : [UIViewController]!
    var currentPageIndex : Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let gagReelVC = self.storyboard?.instantiateViewControllerWithIdentifier("gagReel") as! GagReelViewController
        let cameraVC = self.storyboard?.instantiateViewControllerWithIdentifier("camera") as! CameraViewController
        cameraVC.delegate = self
        let gagFeedVC = self.storyboard?.instantiateViewControllerWithIdentifier("gagFeed") as! GagFeedViewController
        
        // Create an array of ViewController that the PageViewController will use as it's datasource
        self.viewControllers = [UIViewController]()
        self.viewControllers.append(gagReelVC)
        self.viewControllers.append(cameraVC)
        self.viewControllers.append(gagFeedVC)
        
        // Get PageViewController from the storyboard and set the datasource to self
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        // Set the starting ViewContrller for the PageViewController
        let starterViewControllerArray = NSArray(object: cameraVC)
        self.pageViewController.setViewControllers(starterViewControllerArray as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        // Add the PageViewController to self
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
    }
    
    // MARK:  PageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = Int(self.viewControllers.indexOf(viewController)!)
        self.currentPageIndex = index
        self.prefersStatusBarHidden()
        
        if ((index == NSNotFound) || (index == 0)) {
            return nil
        }
        
        index--
        
        return self.viewControllers[index]

    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = Int(self.viewControllers.indexOf(viewController)!)
        self.currentPageIndex = index
        self.prefersStatusBarHidden()
        
        if (index == NSNotFound) {
            return nil
        }
        index++
        
        if (index == self.viewControllers.count) {
            return nil
        }
        
        return self.viewControllers[index]
       
    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        print(self.currentPageIndex)
        
        if (self.currentPageIndex != 1) {
            return false
        }
        
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    // MARK: CameraViewControllerDelegate
    func previousButtonPressed(controller: CameraViewController, sender: UIButton) {
        let vc = self.viewControllers[0] as! GagReelViewController
        let starterViewControllerArray = NSArray(object: vc)
        self.pageViewController.setViewControllers(starterViewControllerArray as? [UIViewController], direction: .Reverse, animated: true, completion: nil)
    }

    func forwardButtonPressed(controller: CameraViewController, sender: UIButton) {
        let vc = self.viewControllers[2] as! GagFeedViewController
        let starterViewControllerArray = NSArray(object: vc)
        self.pageViewController.setViewControllers(starterViewControllerArray as? [UIViewController], direction: .Forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
