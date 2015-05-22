//
//  AttributionTableViewController.swift
//  OpenMRS-iOS
//
//  Created by Parker Erway on 5/22/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

import UIKit

class AttributionTableViewController: UITableViewController {
    var attributions: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Attribution"
        

        if let path = NSBundle.mainBundle().pathForResource("Attribution", ofType: "plist") {
            attributions = NSDictionary(contentsOfFile: path)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return attributions.allKeys.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 0
    }


    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return attributions.allKeys[section] as? String
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return attributions.allValues[section] as? String
    }
}
