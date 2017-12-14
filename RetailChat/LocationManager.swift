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
    private var geoFence: CLCircularRegion!
    
    override init() {
        super.init()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            //print("Entering location enabled if")
            locManager.requestAlwaysAuthorization()
            locManager.distanceFilter = kCLLocationAccuracyBest
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            //geoFence = CLCircularRegion()
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                //print("Entering isMonitoring if")
                let title = "Best Buy Mobile"
                let coordinate = CLLocationCoordinate2D(latitude: 25.758819, longitude: -80.373580)//ECS lab
                //let coordinate = CLLocationCoordinate2D(latitude: (locManager.location?.coordinate.latitude)!, longitude: (locManager.location?.coordinate.longitude)!) //about 25.78755300, -80.38038800 for my location in JCCL lab
                //let coordinate = CLLocationCoordinate2D(latitude: 25.75904, longitude: -80.373845)
                let regionRadius = 1.0
                //25.788682, -80.381460 Best Buy
            
            
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
        print("Error starting location service")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location updating")
        print(manager.location!)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("authorized changes")
            //manager.startUpdatingLocation()
        }
        
        else if status == .denied {
            let alertController = UIAlertController(title: "Error", message: "Please allow access to location services.", preferredStyle: .alert)
            //...
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in exit(0)}))
            var rootViewController = UIApplication.shared.keyWindow?.rootViewController
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Within the region")
        print(manager.location!)
        let alertController = UIAlertController(title: "region", message: "Within the region", preferredStyle: .alert)
        //...
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alertController, animated: true, completion: nil)
        //temp.presentAlert()
        /*if let testRegion = region as? CLCircularRegion {
            let identifier = testRegion.identifier
            if identifier == "Best Buy Mobile" {
                //allow access if within the geofence
            }
        }*/
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited the region")
        print(manager.location!)
        let alertController = UIAlertController(title: "region", message: "exited the region", preferredStyle: .alert)
        //...
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in exit(0)}))
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alertController, animated: true, completion: nil)
        /*if let testRegion = region as? CLCircularRegion {
            let identifier = testRegion.identifier
            if identifier == "Best Buy Mobile" {
                //prevent access if not within the geofence
            }
        }*/
    }
}
