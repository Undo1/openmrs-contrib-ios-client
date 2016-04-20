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

class SelectVisitTypeView : UITableViewController, UIViewControllerRestoration
{
    var visitTypes: [MRSVisitType]! = []
    var delegate: SelectVisitTypeViewDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    override init(style: UITableViewStyle) {
        super.init(style: .Plain)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MRSHelperFunctions.updateTableViewForDynamicTypeSize(self.tableView)
    }

    func updateFontSize() {
        MRSHelperFunctions.updateTableViewForDynamicTypeSize(self.tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restorationIdentifier = NSStringFromClass(self.dynamicType);
        self.restorationClass = self.dynamicType;
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector:#selector(SelectVisitTypeView.updateFontSize), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        MRSHelperFunctions.updateTableViewForDynamicTypeSize(self.tableView)
        
        self.title = NSLocalizedString("Visit Type", comment: "Label -visit- -type-")
        
        self.reloadData()
    }
    func reloadData()
    {
        if self.visitTypes == nil
        {
            MBProgressExtension.showBlockWithTitle(NSLocalizedString("Loading", comment: "Label loading"), inView: self.view)
            OpenMRSAPIManager.getVisitTypesWithCompletion { (error:NSError!, types:[AnyObject]!) -> Void in
                MBProgressExtension.hideActivityIndicatorInView(self.view)
                if error != nil
                {
                    MRSAlertHandler.alertViewForError(self, error: error).show();
                    NSLog("Error getting visit types: \(error)")
                }
                else
                {
                    MBProgressExtension.showSucessWithTitle(NSLocalizedString("Completed", comment: "Label completed"), inView: self.view)
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
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell")
        
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
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        coder.encodeObject(self.delegate as! StartVisitViewController, forKey: "delegate")
        coder.encodeObject(self.visitTypes, forKey: "visitTypes")
    }
    
    static func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        let visitTypeList = SelectVisitTypeView(style: UITableViewStyle.Plain)
        visitTypeList.visitTypes = coder.decodeObjectForKey("visitTypes") as! [MRSVisitType]
        visitTypeList.delegate = coder.decodeObjectForKey("delegate") as! StartVisitViewController
        return visitTypeList
    }
}
