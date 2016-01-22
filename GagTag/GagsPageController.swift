//
//  GagsPageViewController.swift
//  GagTag
//
//  Created by Ryan on 1/20/16.
//  Copyright © 2016 Inndevers. All rights reserved.
//

import UIKit
import Parse

class GagsPageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController : UIPageViewController!
    var pageTitles: NSArray!
    
    var gags: [PFObject]!
    var gagsIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gagsPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        let singleGagVC = self.viewControllerAtIndex(gagsIndex) as SingleGagViewController
        let viewControllers = NSArray(object: singleGagVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
    }
    
    func viewControllerAtIndex(index : Int) -> SingleGagViewController {
        
        if ((self.gags.count == 0) || index >= self.gags.count) {
            return SingleGagViewController()
        }
        
        let vc: SingleGagViewController = self.storyboard?.instantiateViewControllerWithIdentifier("singleGagView") as! SingleGagViewController
        
        vc.pageIndex = index
        let gag = gags[index]
        vc.gagId = gag.objectId
        
        return vc
    }
    
    // MARK:  PageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! SingleGagViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! SingleGagViewController 
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index++
        
        if (index == self.gags.count) {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        print("didFinishAnimating")
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
