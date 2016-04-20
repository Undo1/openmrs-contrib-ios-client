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
        return []
    }
}