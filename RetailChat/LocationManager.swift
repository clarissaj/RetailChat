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
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            self.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
            self.requestAlwaysAuthorization()
            break
        default:
            print("Error")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
}
