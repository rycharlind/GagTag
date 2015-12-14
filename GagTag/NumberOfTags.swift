//
//  NumberOfTagsViewController.swift
//  GagTag
//
//  Created by Ryan on 11/22/15.
//  Copyright © 2015 Inndevers. All rights reserved.
//

import UIKit

protocol NumberOfTagsDelegate {
    func sliderValueChanged(slider: UISlider)
}

class NumberOfTagsViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var slider: UISlider!
    var delegate: NumberOfTagsDelegate?
    
    // MARK: Actinos
    @IBAction func sliderValueChanged(sender: AnyObject) {
        
        delegate?.sliderValueChanged(sender as! UISlider)
        //let slider = sender as! UISlider
        //var userInfo = Dictionary<String, Int>()
        //userInfo["sliderValue"] = Int(slider.value)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
