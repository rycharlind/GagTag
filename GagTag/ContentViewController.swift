//
//  ContentViewController.swift
//  GagTag
//
//  Created by Ryan on 10/9/15.
//  Copyright (c) 2015 Inndevers. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    
    
    @IBOutlet weak var labelTitle: UILabel!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.labelTitle.text = self.titleText
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
