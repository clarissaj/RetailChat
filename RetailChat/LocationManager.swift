//
//  LocationManager.swift
//  RetailChat
//
//  Created by alex alfaro on 12/12/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locManager = CLLocationManager()
    //private var lattitude: Double!
    //private var longitude: Double!
    private var geoFence: CLCircularRegion!
    //var permissionDenied = false
    //var startMonitoring = false
    //var temp = MailsTableViewController(coder: <#NSCoder#>)!
    
    override init() {
        super.init()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            print("Entering location enabled if")
            locManager.requestAlwaysAuthorization()
            locManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            //geoFence = CLCircularRegion()
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                print("Entering isMonitoring if")
                let title = "FIU JCC LAB"
                let coordinate = CLLocationCoordinate2D(latitude: 25.75880555, longitude: -80.37360633)
                let regionRadius = 20.0
            
            
                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), radius: regionRadius, identifier: title)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                geoFence = region
                //startMonitoring = true
                locManager.startMonitoring(for: region)
                
            }
            else {
                print("Can't track region")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        /*let alert = UIAlertController(title: "Error", message: "Unable to start location services.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)*/
        print("Error starting location service")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location updating")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("authorized changes")
            //manager.startUpdatingLocation()
        }
        
        else if status == .denied {
            
        }
    }
    
    //func checkToStartmonitoring() -> Bool {
       // return startMonitoring
    //}
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Within the region")
        //temp.presentAlert()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited the region")
    }
}
