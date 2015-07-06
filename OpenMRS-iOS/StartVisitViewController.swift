//
//  StartVisitViewController.swift
//  OpenMRS-iOS
//
//  Created by Parker Erway on 1/22/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

import UIKit

@objc protocol StartVisitViewControllerDelegate
{
    func didCreateVisitForPatient(patient: MRSPatient)
}

class StartVisitViewController : UITableViewController, SelectVisitTypeViewDelegate, LocationListTableViewControllerDelegate, UIViewControllerRestoration
{
    var visitType: MRSVisitType!
    var cachedVisitTypes: [MRSVisitType]!
    var location: MRSLocation!
    var patient: MRSPatient!
    var delegate: StartVisitViewControllerDelegate!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Grouped)
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

        var defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector:"updateFontSize", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        MRSHelperFunctions.updateTableViewForDynamicTypeSize(self.tableView)

        self.title = NSLocalizedString("Start Visit", comment: "Label -start- -visit-")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        
        self.reloadData()
        
        self.updateDoneButtonState()
    }
    
    func done()
    {
        OpenMRSAPIManager.startVisitWithLocation(location, visitType: visitType, forPatient: patient) { (error:NSError!) -> Void in
            if error == nil
            {
                dispatch_async(dispatch_get_main_queue()) {
                    self.delegate?.didCreateVisitForPatient(self.patient)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    func reloadData()
    {
        OpenMRSAPIManager.getVisitTypesWithCompletion { (error:NSError!, types:[AnyObject]!) -> Void in
            if error == nil
            {
                self.cachedVisitTypes = types as! [MRSVisitType]!
                if types.count == 1
                {
                    self.visitType = types[0] as! MRSVisitType
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        self.updateDoneButtonState()
                    }
                }
            }
        }
    }
    
    func cancel()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section
        {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section
        {
        case 0:
            return NSLocalizedString("Visit Type", comment: "Label -visit- -type-")
        case 1:
            return NSLocalizedString("Location", comment:"Label location")
        default:
            return nil
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section
        {
        case 0:
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("visit_type") as! UITableViewCell!
            
            if cell == nil
            {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "visit_type")
            }
            
            cell.textLabel?.text = NSLocalizedString("Visit Type", comment: "Label -visit- -type-")
            
            if visitType == nil
            {
                cell.detailTextLabel?.text = NSLocalizedString("Select visit Type", comment: "Label -select- -visit- -type-")
            }
            else
            {
                cell.detailTextLabel?.text = visitType.display
            }
            
            cell.accessoryType = .DisclosureIndicator
            
            return cell
        case 1:
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("location") as! UITableViewCell!
            
            if cell == nil
            {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "location")
            }
            
            cell.textLabel?.text = NSLocalizedString("Location", comment:"Label location")
            
            if location == nil
            {
                cell.detailTextLabel?.text = NSLocalizedString("Select Location", comment: "Label -select- -location-")
            }
            else
            {
                cell.detailTextLabel?.text = location.display
            }
            
            cell.accessoryType = .DisclosureIndicator
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section
        {
        case 0:
            let vc = SelectVisitTypeView(style: UITableViewStyle.Plain)
            vc.delegate = self
            vc.visitTypes = cachedVisitTypes
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = LocationListTableViewController(style: UITableViewStyle.Plain)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            return
        }
    }
    func didChooseLocation(newLocation: MRSLocation) {
        location = newLocation
        self.navigationController?.popToRootViewControllerAnimated(true)
        tableView.reloadData()
        self.updateDoneButtonState()
    }
    
    func didSelectVisitType(type: MRSVisitType) {
        visitType = type
        tableView.reloadData()
        self.updateDoneButtonState()
    }
    
    func updateDoneButtonState() {
        self.navigationItem.rightBarButtonItem?.enabled = (location != nil && visitType != nil)
    }
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        coder.encodeObject(self.patient, forKey: "patient")
        coder.encodeObject(self.delegate, forKey: "delegate")
        let nils:[Bool] = [self.visitType == nil, self.location == nil]
        coder.encodeObject(nils, forKey:"nils")
        coder.encodeObject(self.visitType, forKey: "visitType")
        coder.encodeObject(self.location, forKey: "location")
    }
    
    static func viewControllerWithRestorationIdentifierPath(identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        let startVisit: StartVisitViewController = StartVisitViewController(style: UITableViewStyle.Grouped)
        startVisit.patient = coder.decodeObjectForKey("patient") as! MRSPatient
        startVisit.delegate = coder.decodeObjectForKey("delegate") as! StartVisitViewControllerDelegate
        let nils:[Bool] = coder.decodeObjectForKey("nils") as! Array
        if (nils[0]==false) {
            startVisit.visitType = coder.decodeObjectForKey("visitType") as! MRSVisitType;
        }
        if (nils[1]==false) {
            startVisit.location = coder.decodeObjectForKey("location") as! MRSLocation
        }
        return startVisit
    }
}