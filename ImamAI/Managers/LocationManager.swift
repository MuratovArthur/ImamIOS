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
    @Published var deviceHeading: Double = 0.0
    @Published var qiblaDirection: Double = 0.0
    private let kaabaLatitude = 21.4225
    private let kaabaLongitude = 39.8262
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startUpdating() {
        locationManager.startUpdatingHeading()
    }

    func stopUpdating() {
        locationManager.stopUpdatingHeading()
    }
    
    func calculateQiblaDirection(from location: CLLocation) -> Double {
        let userLatitude = degreesToRadians(degrees: location.coordinate.latitude)
        let userLongitude = degreesToRadians(degrees: location.coordinate.longitude)
        let kaabaLatitude = degreesToRadians(degrees: self.kaabaLatitude)
        let kaabaLongitude = degreesToRadians(degrees: self.kaabaLongitude)

        let numerator = sin(kaabaLongitude - userLongitude)
        let denominator = cos(userLatitude) * tan(kaabaLatitude) - sin(userLatitude) * cos(kaabaLongitude - userLongitude)
        var direction = atan2(numerator, denominator)

        // Convert from radians to degrees
        direction = radiansToDegrees(radians: direction)

        // atan2() function returns values between -180 to 180 degrees. We need to convert it to 0 to 360 degrees
        if direction < 0 {
            direction += 360
        }

        return direction
    }

    func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180
    }

    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180 / .pi
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Check the timestamp of the location, only accept it if it's recent (less than 15 seconds old in this example)
        if location.timestamp.timeIntervalSinceNow < -15 {
            print("Location data is too old.")
            return
        }

        self.location = location
        self.qiblaDirection = calculateQiblaDirection(from: location)
        manager.stopUpdatingLocation()
        print("Location updated: \(location)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.deviceHeading = newHeading.trueHeading // This is the device heading.
        }
    }
}
