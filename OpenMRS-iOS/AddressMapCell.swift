//
//  AddressMapCell.swift
//  OpenMRS-iOS
//
//  Created by Parker on 4/20/16.
//  Copyright © 2016 Erway Software. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddressMapCell : UITableViewCell
{
    var mapView: MKMapView!

    var location: CLLocationCoordinate2D!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(location: CLLocationCoordinate2D, reuseIdentifier: String)
    {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)

        self.location = location

        mapView = MKMapView(frame: self.bounds)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.userInteractionEnabled = false

        self.contentView.addSubview(mapView)

        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)

        let annotation = PatientAddressAnnotation(coordinate: location, title: "", subtitle: "")
        mapView.addAnnotation(annotation)

        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview" : mapView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview" : mapView]))
    }
}