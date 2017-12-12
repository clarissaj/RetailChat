//
//  LocationManager.swift
//  RetailChat
//
//  Created by alex alfaro on 12/7/17.
//  Copyright © 2017 FIU. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    override init() {
        super.init()
        self.delegate = self
    }
    
    func enableLocationServices() {
        //print("entering function")
        self.startUpdatingLocation()
        if CLLocationManager.locationServicesEnabled() {
            //print("entering if")
            //CLLocationManager.requestWhenInUseAuthorization(self)
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                self.requestWhenInUseAuthorization()
                break
            case .authorizedWhenInUse:
                self.requestWhenInUseAuthorization()
                print("authorized when in use enabled")
                break
            case .authorizedAlways:
                self.requestAlwaysAuthorization()
                break
            default:
                print("Error")
            }
            self.startUpdatingLocation()
            //self.requestLocation()
        }
    }
        
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Services unavaliable")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("authorization changed")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("new location data available")
        print(locations.first!)
    }
}
