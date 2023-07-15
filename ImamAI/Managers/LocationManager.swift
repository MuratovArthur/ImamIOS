//
//  LocationManager.swift
//  ImamAI
//
//  Created by Muratov Arthur on 15.07.2023.
//

import Foundation
import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Check the timestamp of the location, only accept it if it's recent (less than 15 seconds old in this example)
        if location.timestamp.timeIntervalSinceNow < -15 {
            return
        }
        
        self.location = location
        manager.stopUpdatingLocation()
    }
}
