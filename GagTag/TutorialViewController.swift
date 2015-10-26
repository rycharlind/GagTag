//
//  TutorialViewController.swift
//  GagTag
//
//  Created by Ryan on 10/9/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource, MainNavDelegate {
    
    var pageViewController : UIPageViewController!
    var pageTitles: NSArray!
    var viewControllers : [UIViewController]!
    var currentPageIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let tutPage1VC = self.storyboard?.instantiateViewControllerWithIdentifier("tutPage1") as! TutPageController1
        tutPage1VC.mainNavDelegate = self
        
        let tutPage2VC = self.storyboard?.instantiateViewControllerWithIdentifier("tutPage2")
        let tutPage3VC = self.storyboard?.instantiateViewControllerWithIdentifier("tutPage3")
        
        // Create an array of ViewController that the PageViewController will use as it's datasource
        self.viewControllers = [UIViewController]()
        self.viewControllers.append(tutPage1VC)
        self.viewControllers.append(tutPage2VC!)
        self.viewControllers.append(tutPage3VC!)
        
        // Get PageViewController from the storyboard and set the datasource to self
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tutorialPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        // Set the starting ViewContrller for the PageViewController
        let starterViewControllerArray = NSArray(object: tutPage1VC)
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
        
        if((index == NSNotFound) || index == 0){
            return nil
        }
        
        index--
        return self.viewControllers[index]
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = Int(self.viewControllers.indexOf(viewController)!)
        self.currentPageIndex = index
        self.prefersStatusBarHidden()
        
        if(index == NSNotFound){
            return nil
        }
        index++
        
        if (index == self.viewControllers.count){
            return nil
        }
        
        return self.viewControllers[index]
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        print(self.currentPageIndex)
        
        if(self.currentPageIndex != 1 ){
            return false
        }
    
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.viewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.currentPageIndex
    }
    
    // MARK: MainNavController
    func goToController(index: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool){
        let vc = self.viewControllers[index] as UIViewController
        let starterViewControllerArray = NSArray(object: vc)
        self.pageViewController.setViewControllers(starterViewControllerArray as? [UIViewController], direction: direction, animated: animated, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
