//
//  SelectVisitTypeView.swift
//  
//
//  Created by Parker Erway on 1/22/15.
//
//

import UIKit

protocol SelectVisitTypeViewDelegate
{
    func didSelectVisitType(type: MRSVisitType)
}

class SelectVisitTypeView : UITableViewController
{
    var visitTypes: [MRSVisitType]! = []
    var delegate: SelectVisitTypeViewDelegate!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override init(style: UITableViewStyle) {
        super.init(style: .Plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Visit Type", comment: "Label -visit- -type-")
        
        self.reloadData()
    }
    func reloadData()
    {
        if self.visitTypes == nil
        {
            
            OpenMRSAPIManager.getVisitTypesWithCompletion { (error:NSError!, types:[AnyObject]!) -> Void in
                if error != nil
                {
                    NSLog("Error getting visit types: \(error)")
                }
                else
                {
                    self.visitTypes = types as! [MRSVisitType]
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visitTypes.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell!
        
        if cell == nil
        {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        }
        
        let visitType = self.visitTypes[indexPath.row]
        
        cell.textLabel?.text = visitType.display
        
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let visitType = visitTypes[indexPath.row]
        delegate.didSelectVisitType(visitType)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
