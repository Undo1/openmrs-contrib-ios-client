//
//  MapViewController.swift
//  OpenMRS-iOS
//
//  Created by Parker on 4/19/16.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController : UIViewController
{
    var patient: MRSPatient! {
        didSet {
            self.title = patient.name
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(patient.formattedPatientAddress()) { (placemark: [CLPlacemark]?, error: NSError?) in
                if placemark != nil && !(placemark?.isEmpty)!
                {                    
                    let place = placemark![0]
                    self.mapView.setCenterCoordinate((place.location?.coordinate)!, animated: true)
                    
                    let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                    let region = MKCoordinateRegion(center: (place.location?.coordinate)!, span: span)
                    
                    self.mapView.setRegion(region, animated: true)
                    
                    let annotation = PatientAddressAnnotation(coordinate: (place.location?.coordinate)!)
                    self.mapView.addAnnotation(annotation)
                }
                else
                {
                    self.navigationController?.popViewControllerAnimated(true)
                    
                    let alert = UIAlertController(title: "Couldn't find address", message: "It may be spelled incorrectly", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    
                    self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    var mapView: MKMapView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        mapView = MKMapView(frame: self.view.bounds)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)

        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview" : mapView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview" : mapView]))
    }
    
}