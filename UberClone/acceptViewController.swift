//
//  acceptViewController.swift
//  UberClone
//
//  Created by apple on 10/02/18.
//  Copyright © 2018 Sonkar. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class acceptViewController: UIViewController {

    var requestLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    var driverLocation = CLLocationCoordinate2D()
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        
        map.addAnnotation(annotation)

    }

    @IBAction func acceptRequestapped(_ sender: UIButton) {
        
        Database.database().reference().child("RiderRequest").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat": self.driverLocation.latitude, "driverLong": self.driverLocation.longitude])
            
            Database.database().reference().child("RiderRequest").removeAllObservers()
            
            //open maps
            
            let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
            CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                
                if let marks = placemarks{
                    if marks.count > 0{
                        let placemark = MKPlacemark(placemark: marks[0])
                        let mapItem  = MKMapItem(placemark: placemark)
                        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions: options)
                        
                    }
                    
                }
            })
        }
    }
}
