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
    
    override init() {
        super.init()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.requestAlwaysAuthorization()
            locManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
        }
    }
    
    // Function called when the location got updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location updating")
        let locValue : CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    
    func locationInBounds(_ locValue : CLLocationCoordinate2D) -> Bool{
        // ECS Room values
        let latLeft = 25.758902966939928
        let latRight = 25.75873870059714
        let lonDown = -80.37342846393585
        let lonUp = -80.37373155355453
        
        if locValue.latitude <= latLeft && locValue.latitude >= latRight && locValue.longitude <= lonDown && locValue.longitude >= lonUp{
            return true
        }
        else{
            return false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        let alertController = UIAlertController(title: "Error", message: "There was an error while fetching your location. Exiting.", preferredStyle: .alert)
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
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("authorized changes")
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

    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
        let alertController = UIAlertController(title: "Error", message: "Error monitoring the specified region.", preferredStyle: .alert)
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
    
    // Return the coordinates of the user
    func getCoordinates() -> CLLocationCoordinate2D{
        return (locManager.location?.coordinate)!
    }
    
    // Stop updating
    func stopUpdates(){
        locManager.stopUpdatingLocation()
    }
}
