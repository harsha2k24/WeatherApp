//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import Foundation

/// Protocol defining the requirements for a weather service
/// that fetches weather data for a given city.

protocol WeatherServiceProtocol {
    /// Fetches weather data for a specified city.
    /// - Parameter city: The name of the city to fetch weather data for.
    /// - Returns: A `WeatherData` object containing the weather information.
    /// - Throws: An error of type `WeatherServiceError` if the request fails.

    func fetchWeather(for city: String) async throws -> WeatherData
}
/// Enum representing possible errors that can occur while fetching weather data.

enum WeatherServiceError: Error {
    case invalidURL           // The URL is invalid.
    case networkError(Error)   // A network error occurred.
    case serverError(Int)      // The server returned an error status code.
    case decodingError         // The data could not be decoded.

}
/// A class that provides weather data for a specific city
/// by making network requests to a weather API.
///
/// This Class Can be further extended to support multiple types of HTTP calls like GET & POST & Others
class WeatherService: WeatherServiceProtocol {
    
    // Can store these Kind of API Keys in .xcConfig files to maintain security
    private let apiKey = "8e1e5bfbfe4fe158068bf8aa93bc3756"
    
    /// Fetches weather data for a specified city/State/country.
    ///
    /// This method constructs a URL with the specified city name,
    /// sends an asynchronous network request, and decodes the response
    /// into a `WeatherData` object.
    ///
    /// - Parameter city: The name of the city to retrieve weather information for.
    /// - Returns: A `WeatherData` object containing weather details for the city.
    /// - Throws: A `WeatherServiceError` in case of an invalid URL, network error,
    ///           server error, or decoding error.
    func fetchWeather(for city: String) async throws -> WeatherData {
        let formattedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = Constants.baseURL + "?q=\(formattedCity)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidURL
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check for server error
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw WeatherServiceError.serverError(httpResponse.statusCode)
            }
            
            // Decode the data
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                return weatherData
            } catch {
                throw WeatherServiceError.decodingError
            }
            
        } catch {
            throw WeatherServiceError.networkError(error)
        }
    }
}
