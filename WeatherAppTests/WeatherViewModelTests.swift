//
//  ViewModelTests.swift
//  WeatherAppTests
//
//  Created by Harsha on 11/06/24.
//

@testable import WeatherApp
import XCTest
import Combine

final class WeatherViewModelTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var mockService: MockWeatherService!
    var cancellables: Set<AnyCancellable>!

    func getWeatherModel() -> WeatherData? {
        let mockWeatherData = """
                {
                    "coord": {"lat": 37.7749, "lon": -122.4194},
                    "main": {"temp": 295.15},
                    "wind": {"speed": 5.14},
                    "weather": [{"description": "clear sky", "icon": "01d"}]
                }
                """.data(using: .utf8)!
        let weatherData = try? JSONDecoder().decode(WeatherData.self, from: mockWeatherData)
        return weatherData
    }
    override func setUp() {
        super.setUp()
        mockService = MockWeatherService()
        viewModel = WeatherViewModel(weatherService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    func testFetchWeatherSuccess() async {
        // Arrange
        let expectation = XCTestExpectation(description: "Weather data fetch should succeed and update on the main thread")
        let weatherData = getWeatherModel()
        mockService.weatherData = weatherData
        viewModel.apiState = .idle
        
        // Act
        viewModel.fetchWeather(for: "San Francisco")
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertEqual(self.viewModel.apiState, .success)
            XCTAssertEqual(self.viewModel.weather?.coord?.lat, 37.7749)
            XCTAssertEqual(self.viewModel.weather?.main?.temp, 295.15)
            XCTAssertTrue(Thread.isMainThread, "State update should occur on main thread")
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testFetchWeatherFailure() async throws {
        // Arrange
        let expectation = XCTestExpectation(description: "Weather data fetch should succeed and update on the main thread")

        mockService.shouldReturnError = true
        viewModel.apiState = .idle

        // Act
        viewModel.fetchWeather(for: "InvalidCity")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertEqual(self.viewModel.apiState, .error("Network error: No internet connection"))
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testMainThreadExecutionOnSuccess() async throws {
        let expectation = XCTestExpectation(description: "Weather data fetch should succeed and update on the main thread")
        mockService.weatherData = getWeatherModel()
        // Act
        viewModel.fetchWeather(for: "San Francisco")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Assert main thread
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(self.viewModel.apiState, .success)

            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
    }

    func testMainThreadExecutionOnError() async throws {
        let expectation = XCTestExpectation(description: "Weather data fetch should succeed and update on the main thread")

        // Arrange
        mockService.shouldReturnError = true

        // Act
        viewModel.fetchWeather(for: "InvalidCity")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Assert main thread
            // Assert main thread
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(self.viewModel.apiState, .error("Network error: No internet connection"))

            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 2.0)
    }
}

class MockWeatherService: WeatherServiceProtocol {
    var shouldReturnError = false
    var weatherData: WeatherData?

    func fetchWeather(for city: String) async throws -> WeatherData {
        if shouldReturnError {
            throw WeatherServiceError.networkError(NSError(domain: "", code: -1009, userInfo: [NSLocalizedDescriptionKey: "No internet connection"]))
        }
        if let weatherData = weatherData {
            return weatherData
        }
        throw WeatherServiceError.invalidURL
    }
}
