//
//  driverTableViewController.swift
//  
//
//  Created by apple on 06/02/18.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class driverTableViewController: UITableViewController, CLLocationManagerDelegate  {
    
    var driverLocation = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    var rideRequests : [DataSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        Database.database().reference().child("RiderRequest").observe(.childAdded) { (snapshot) in
            //getting current loaction of driver
            
            //to remove accepted requests from table
            if let rideRequestDictionary = snapshot.value as? [String: Any]{
                if let lat = rideRequestDictionary["driverLat"] as? Double
                {
                    
                }else{
                    self.rideRequests.append(snapshot)
                    self.tableView.reloadData()

                }
                
            }
            
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate{
            driverLocation = coord
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        let snapshot = rideRequests[indexPath.row]
        if let rideRequestDictionary = snapshot.value as? [String: Any]{
            
            if let email = rideRequestDictionary["email"] as? String{
                //cell.textLabel?.text = email
                
                if let lat = rideRequestDictionary["lat"] as? Double
                {
                    if let lon = rideRequestDictionary["long"] as? Double
                    {
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                        let roundDistance = round(distance * 100) / 100
                        
                        cell.textLabel?.text = "\(email) - \(roundDistance) km away"
                        
                    }
                }
            }
        }
        return cell
    }
    
    
    
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let  acceptVC = segue.destination as? acceptViewController{
            
            //forwarding details of rider and driver locations to accept view controller
            
            if let snapshot = sender as? DataSnapshot
            {
                if let rideRequestDictionary = snapshot.value as? [String: Any]{
                    
                    if let email = rideRequestDictionary["email"] as? String{
                        
                        if let lat = rideRequestDictionary["lat"] as? Double
                        {
                            if let lon = rideRequestDictionary["long"] as? Double
                            {
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                acceptVC.requestEmail = email
                                acceptVC.requestLocation = location
                                acceptVC.driverLocation.latitude  = driverLocation.latitude
                                acceptVC.driverLocation.longitude = driverLocation.longitude
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}
