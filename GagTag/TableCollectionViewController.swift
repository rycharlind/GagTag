//
//  TableCollectionViewController.swift
//  GagTag
//
//  Created by Ryan on 1/4/16.
//  Copyright © 2016 Inndevers. All rights reserved.
//

import UIKit
import Parse

class TableCollectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CollectionTableViewCellDelgate {
    
    @IBOutlet weak var tableView: UITableView!
    var multiRowHeight = 3850

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return 110
        default:
            return CGFloat(multiRowHeight)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch (indexPath.row) {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("SingleRowCell") as! SingleRowCollectionTableViewCell!
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("CollectionCell") as! CollectionTableViewCell!
            cell.delegate = self
            return cell
            
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    // MARK: CollectionTableViewCellDelgate
    func didCompleteQuery(objects: [PFObject]) {
        //self.multiRowHeight = (objects.count / 3) * 110
        //print(objects.count)
        //print(multiRowHeight)
        //self.tableView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
