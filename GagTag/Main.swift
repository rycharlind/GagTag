//
//  MainViewController.swift
//  GagTag
//
//  Created by Ryan on 10/12/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit
import Parse
import ParseUI

extension UIColor {
    static var blue:UIColor { return UIColor(red: 91/255, green: 192/255, blue: 235/255, alpha: 1) }
    static var yellow:UIColor { return UIColor(red: 252/255, green: 231/255, blue: 76/255, alpha: 1) }
    static var green:UIColor { return UIColor(red: 155/255, green: 197/255, blue: 61/255, alpha: 1) }
    static var red:UIColor { return UIColor(red: 229/255, green: 89/255, blue: 52/255, alpha: 1) }
    static var orange:UIColor { return UIColor(red: 250/255, green: 121/255, blue: 33/255, alpha: 1) }
}

protocol MainNavDelegate {
    func goToController(index: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool)
}

class MainViewController: UIViewController,UIPageViewControllerDelegate, UIPageViewControllerDataSource, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, MainNavDelegate {
    
    var pageViewController : UIPageViewController!
    var viewControllers : [UIViewController]!
    var currentPageIndex : Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let gagReelVC = self.storyboard?.instantiateViewControllerWithIdentifier("gagReel") as! GagReelViewController
        gagReelVC.mainNavDelegate = self
        
        let notificationsVC = self.storyboard?.instantiateViewControllerWithIdentifier("notifications") as! NotificationsViewController
        notificationsVC.mainNavDelegate = self
        
        let cameraVC = self.storyboard?.instantiateViewControllerWithIdentifier("camera") as! CameraViewController
        cameraVC.mainNavDelegate = self
        
        let gagFeedVC = self.storyboard?.instantiateViewControllerWithIdentifier("gagFeed") as! GagFeedViewController
        gagFeedVC.mainNavDelegate = self
        
        let discoverVC = self.storyboard?.instantiateViewControllerWithIdentifier("discover") as! DiscoverViewController
        discoverVC.mainNavDelegate = self
        
        //let tableCollectionVC = self.storyboard?.instantiateViewControllerWithIdentifier("tableCollection") as! TableCollectionViewController
        
        // Create an array of ViewController that the PageViewController will use as it's datasource
        self.viewControllers = [UIViewController]()
        //self.viewControllers.append(gagReelVC)
        self.viewControllers.append(notificationsVC)
        self.viewControllers.append(cameraVC)
        //self.viewControllers.append(gagFeedVC)
        self.viewControllers.append(discoverVC)
        //self.viewControllers.append(tableCollectionVC)
        
        // Get PageViewController from the storyboard and set the datasource to self
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("mainPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
    
        
        // Set the starting ViewContrller for the PageViewController
        let starterViewControllerArray = NSArray(object: cameraVC)
        self.pageViewController.setViewControllers(starterViewControllerArray as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        self.pageViewController.delegate = self
        
        // Add the PageViewController to self
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.prefersStatusBarHidden()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let currentUser = PFUser.currentUser()
        if currentUser == nil {
            showParseLogin()
        }
    }
    
    func showParseLogin() {
        
        // Not sure why I cannot assign the same UILabel to two different UIView's
        let labelLoginGagTag = UILabel()
        labelLoginGagTag.text = "GagTag"
        labelLoginGagTag.font = UIFont(name: labelLoginGagTag.font.fontName, size: 40)
        
        let labelSignUpGagTag = UILabel()
        labelSignUpGagTag.text = "GagTag"
        labelSignUpGagTag.font = UIFont(name: labelSignUpGagTag.font.fontName, size: 40)
        
        let parseLoginViewController = PFLogInViewController()
        parseLoginViewController.delegate = self
        parseLoginViewController.logInView?.logo = labelLoginGagTag
        
        let parseSignUpViewController = PFSignUpViewController()
        parseSignUpViewController.delegate = self
        parseSignUpViewController.signUpView?.logo = labelSignUpGagTag
        
        parseLoginViewController.signUpController = parseSignUpViewController
        
        self.presentViewController(parseLoginViewController, animated: true, completion: nil)
    }
    
    // MARK: PFLogInViewControllerDelegate
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        
        if (!username.isEmpty || !password.isEmpty) {
            return true
        } else {
            return false
        }
        
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.registerForPushNotifications()
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.registerForPushNotifications()
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
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        print("Page Index: \(self.currentPageIndex)")
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        
        //print(self.currentPageIndex)
        
        if (self.currentPageIndex != 1) {
            return false
        }
        
        return true
    }
    
    func registerForPushNotifications() {
        let userNotiicationTypes : UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound])
        let settings : UIUserNotificationSettings = UIUserNotificationSettings(forTypes: userNotiicationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    // MARK: MainNavController 
    func goToController(index: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        let vc = self.viewControllers[index] as UIViewController
        let starterViewControllerArray = NSArray(object: vc)
        self.pageViewController.setViewControllers(starterViewControllerArray as? [UIViewController], direction: direction, animated: animated, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
