//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import Foundation
import UIKit
import Combine

/// Enum representing the various states of the API call.
enum APIState: Equatable {
    case idle
    case loading
    case success
    case empty
    case error(String)
}

/// A view model class responsible for handling weather data and API states.
///
/// This class fetches weather data for a city using `WeatherServiceProtocol`, manages
/// the state of the API call, and loads weather icons. It also stores and retrieves cached data.

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherData?
    @Published var apiState: APIState = .idle
    @Published var weatherIcon: UIImage?
    
    private let weatherService: WeatherServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    @Published var searchQuery = ""
    
    private let locationManager = LocationManager()

    /// Initializes the `WeatherViewModel` with a weather service instance.
    ///
    /// - Parameter weatherService: An instance conforming to `WeatherServiceProtocol` for fetching weather data.

    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
        
        // Retrieve cached weather data, if available, and set the initial state.
        if let model = CacheStorage.retrieve(Constants.jsonFile, from: .documents, as: WeatherData.self) {
            self.weather = model
            self.loadWeatherIcon(iconCode: weather?.weather?.first?.icon)
            self.apiState = .success
        }
        // Debounce and process the search query
        $searchQuery
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] city in
                guard !city.isEmpty else { return }
                self?.fetchWeather(for: city)
            }
            .store(in: &cancellables)
        // Listens for location updates and fetches weather for the updated location.
        self.locationManager.$cityStateCountry
            .sink { [weak self] cityStateCountry in
                if !cityStateCountry.isEmpty  {
                    self?.fetchWeather(for: cityStateCountry)
                }
            }
            .store(in: &cancellables)
    }
    /// Fetches weather data for a specified city.
    ///
    /// - Parameter city: The name of the city for which weather data is to be fetched.

    func fetchWeather(for city: String) {
        guard !city.isEmpty else {
            self.weather = nil
            self.apiState = .idle
            return
        }
        apiState = .loading
        // Asynchronously fetch weather data to prevent blocking the main thread.

        Task { [weak self] in /// To Avoid strong retain cycles
            guard let self = self else { return } // Prevents the rest of the code from running if self is nil.
            do {
                let weatherData = try await weatherService.fetchWeather(for: city)
                runOnMainThread { [weak self] in /// To Avoid strong retain cycles
                    guard let self = self else { return } // Prevents the rest of the code from running if self is nil.
                    self.weather = weatherData
                    self.apiState = .success
                    CacheStorage.store(weatherData, to: .documents, as: Constants.jsonFile)
                    self.loadWeatherIcon(iconCode: weatherData.weather?.first?.icon)
                }
            } catch {
                // Handles any errors encountered during the API call.
                runOnMainThread { [weak self] in /// To Avoid strong retain cycles
                    guard let self = self else { return } // Prevents the rest of the code from running if self is nil.
                    self.apiState = .error(self.getErrorMessage(for: error))
                }
            }
        }
    }
    
    /// Loads the weather icon for a specified icon code.
    ///
    /// - Parameter iconCode: The code for the weather icon to be loaded.

    private func loadWeatherIcon(iconCode: String?) {
        guard let iconCode = iconCode else { return }
        
        // Retrieves cached icon image if available.
        if let image = CacheStorage.retrieveImage(from: .caches, fileName: iconCode) {
            self.weatherIcon = image
            return
        }
        let iconUrl = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
        /// If time permits ImageView class to make the Async image view 
        Task { [weak self] in /// To Avoid strong retain cycles
            guard let self = self else { return } // Prevents the rest of the code from running if self is nil.
            do {
                let (data, _) = try await URLSession.shared.data(from: iconUrl!)
                if let image = UIImage(data: data) {
                    runOnMainThread { [weak self] in /// To Avoid strong retain cycles
                        guard let self = self else { return } // Prevents the rest of the code from running if self is nil.
                        self.weatherIcon = image
                        CacheStorage.storeImage(image, to: .caches, as: iconCode)
                    }
                }
            } catch {
                // Handle icon loading error if needed or load default icon for weather
            }
        }
    }
    /// Generates an error message based on the error type.
    ///
    /// - Parameter error: The error encountered during the API call.
    /// - Returns: A descriptive error message as a `String`.
    func getErrorMessage(for error: Error) -> String {
        switch error {
        case WeatherServiceError.invalidURL:
            return "The URL provided is invalid."
        case WeatherServiceError.networkError(let networkError):
            return "Network error: \(networkError.localizedDescription)"
        case WeatherServiceError.serverError(let statusCode):
            return "Server error with status code \(statusCode)"
        case WeatherServiceError.decodingError:
            return "Failed to decode data from server."
        default:
            return "An unknown error occurred. Please try again."
        }
    }
}
