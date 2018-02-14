//
//  RiderViewController.swift
//  UberClone
//
//  Created by apple on 04/02/18.
//  Copyright © 2018 Sonkar. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var callUber: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()  //to store users lat and long
    var uberCalled = false
    var driverLocation = CLLocationCoordinate2D()
    var driverOnWay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetching current location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email{
            Database.database().reference().child("RiderRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                self.uberCalled = true
                self.callUber.setTitle("Cancel Uber", for: .normal)
                Database.database().reference().child("RiderRequest").removeAllObservers()
                
                //displaying driver in map after an uber is called
                if let rideRequestDictionary = snapshot.value as? [String: Any]{
                    if let lat = rideRequestDictionary["driverLat"] as? Double
                    {
                        if let long = rideRequestDictionary["driverLong"] as? Double
                        {
                            self.driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            
                            self.driverOnWay = true
                            self.DisplayDriverAndRider()
                            
                            if let email = Auth.auth().currentUser?.email{
                                Database.database().reference().child("RiderRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                    
                                    if let rideRequestDictionary = snapshot.value as? [String: Any]{
                                        if let lat = rideRequestDictionary["driverLat"] as? Double
                                        {
                                            if let long = rideRequestDictionary["driverLong"] as? Double
                                            {
                                                self.driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                                
                                                self.driverOnWay = true
                                                self.DisplayDriverAndRider()
                                            }
                                        }
                                    }
                                })
                            }
                            
                        }
                    }
                }
                
            })
        }
        
    }
    
    func DisplayDriverAndRider() //to diplay both in map
    {
        
        
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundDistance = round(distance * 100) / 100
        
        
        callUber.setTitle("Your UBER is \(roundDistance) km  away!", for: .normal)//changing button to tell current distance
        
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.05
        let longDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.05
        //0.05 is extra buffer
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
        map.setRegion(region, animated: true)
        //two different annotations
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = userLocation
        userAnnotation.title = "Your Location"
        map.addAnnotation(userAnnotation)
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Your UBER"
        map.addAnnotation(driverAnnotation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //displaying current location in map
        if let coord = manager.location?.coordinate{
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            
            
            if uberCalled{
                //if uber called diplay both
                DisplayDriverAndRider()
            }else
            {
                //if not called yet display rider only
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                map.setRegion(region, animated: true)
                map.removeAnnotations(map.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                map.addAnnotation(annotation)
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func CallUberTapped(_ sender: Any) {
        
        if !driverOnWay{
            if let email = Auth.auth().currentUser?.email {
                if uberCalled{
                    
                    callUber.setTitle("Call an UBER", for: .normal)
                    uberCalled = false
                    
                    Database.database().reference().child("RiderRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                        
                        snapshot.ref.removeValue()
                        
                        Database.database().reference().child("RiderRequest").removeAllObservers()
                        
                    })
                    
                }else{
                    let riderRequestsDictionary : [String : Any] = ["email" : email , "lat": userLocation.latitude, "long": userLocation.longitude ]
                    Database.database().reference().child("RiderRequest").childByAutoId().setValue(riderRequestsDictionary)
                    
                    uberCalled = true
                    callUber.setTitle("Cancel UBER", for: .normal)
                    
                    
                }
            }
        }
    }
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    
    
}
