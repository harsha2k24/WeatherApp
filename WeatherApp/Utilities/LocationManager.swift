//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import Foundation
import CoreLocation


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    @Published var cityStateCountry: String = ""

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        checkAuthorizationStatus()

    }
    private func checkAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // Request location permission when needed
        case .restricted, .denied:
            // Handle the case where location services are denied or restricted
            print("Location services are restricted or denied")
        case .authorizedWhenInUse, .authorizedAlways:
            // Location access is already granted, start location updates
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate method to handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            reverseGeocode(location)
            stopLocationUpdates()  // Stop updates once the location is fetched
            ///Once the location fetched we are stopping the locations to improve the battery performance
        }
    }

    // CLLocationManagerDelegate method to handle location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    // Handle permission changes gracefuly based on requirements
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location access denied or restricted")
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
            startLocationUpdates()
        @unknown default:
            print("Unknown location status")
        }
    }
    private func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Error reverse geocoding: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemark found")
                return
            }
            
            // Extract city, state, and country code
            let cityName = placemark.locality ?? ""
            let stateCode = placemark.administrativeArea ?? ""
            let countryCode = placemark.country ?? ""
            self?.cityStateCountry = cityName + "," + stateCode + "," + countryCode
        }
    }

}
