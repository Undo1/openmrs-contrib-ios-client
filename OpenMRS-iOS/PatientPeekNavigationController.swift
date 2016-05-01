//
//  PatientPeekNavigationController.swift
//  OpenMRS-iOS
//
//  Created by Parker on 4/19/16.
//  Copyright © 2016 Erway Software. All rights reserved.
//

import UIKit

class PatientPeekNavigationController : UINavigationController {
    var patient: MRSPatient!
    var searchController: PatientSearchViewController!
    
    @available(iOS 9.0, *)
    override func previewActionItems() -> [UIPreviewActionItem] {
        let editAction = UIPreviewAction(title: NSLocalizedString("Edit patient", comment: "Title -Edit- -patient-"), style: .Default) { (action: UIPreviewAction, viewController: UIViewController) in
            let navigationController = viewController as! UINavigationController
            let patientViewController = navigationController.viewControllers[0] as! PatientViewController

            patientViewController.presentEditViewController(patientViewController.patient, fromViewController: UIApplication.sharedApplication().keyWindow?.rootViewController)
        }

        return [editAction]
    }
}