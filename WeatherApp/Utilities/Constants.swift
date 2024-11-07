//
//  Constants.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import Foundation
/// App constants
struct Constants {
    static let viewCornerRadius = 6.0
    /// The Base URL's also can maintain in xcConfig files or .plist files to supoort multiple environment slike DEV/QA/PROD
    static let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    static let noResultsFound = "No results found.".localized
    static let idleMessage = "Search by City or state to get weather.".localized
    static let error = "Error:".localized
    static let AppName = "Weather".localized
    static let jsonFile = "WeatherData.json"
    static let latitude = "Latitude:".localized
    static let longitude = "Longitude:".localized
    static let temperature = "Temperature:".localized
    static let windSpeed = "Wind Speed:".localized
    static let searchPlaceHolder = "Search Placeholder".localized


}
