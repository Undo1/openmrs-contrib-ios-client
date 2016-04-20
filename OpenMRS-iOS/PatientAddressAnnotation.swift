//
//  PatientAddressAnnotation.swift
//  OpenMRS-iOS
//
//  Created by Parker on 4/19/16.
//  Copyright © 2016 Erway Software. All rights reserved.
//

import MapKit

class PatientAddressAnnotation : NSObject, MKAnnotation {
    @objc var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    // Title and subtitle for use by selection UI.
    @objc var title: String?
    @objc var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?)
    {
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}