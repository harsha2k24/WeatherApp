//
//  ContentView.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    var coordinator: MainCoordinator?
    var body: some View {
        
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchQuery)
                    .onChange(of: viewModel.searchQuery) { newValue in
                        // Trigger search or any other logic when the text changes
                        if newValue.isEmpty {
                            viewModel.apiState = .empty
                        }
                    }
                switch viewModel.apiState {
                case .idle:
                    Text(Constants.idleMessage)
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                        .accessibilityLabel("Idle. \(Constants.idleMessage)")
                case .loading:
                    ProgressView()
                        .scaleEffect(2)
                        .padding(.top, 20)
                        .accessibilityLabel("Loading weather data")
                    
                case .success:
                    if let weather = viewModel.weather {
                        HStack(spacing: 10) {
                            // Display Weather Icon
                            if let icon = viewModel.weatherIcon {
                                Image(uiImage: icon)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .padding(0)
                                    .accessibilityLabel("Weather icon")
                            }
                            VStack {
                                WeatherInfoRow(label: Constants.latitude, value: "\(weather.coord?.lat ?? 0.0)")
                                WeatherInfoRow(label: Constants.longitude, value: "\(weather.coord?.lon ?? 0.0)")
                                WeatherInfoRow(label: Constants.temperature, value: "\(Int(weather.main?.temp ?? 0.0 - 273.15))°C")
                                WeatherInfoRow(label: Constants.windSpeed, value: "\(weather.wind?.speed ?? 0.0) m/s")
                            }
                        }
                        .padding()
                        .accessibilityElement(children: .combine) // Group the data in HStack for VoiceOver

                    }
                    
                case .empty:
                    Text(Constants.noResultsFound)
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                        .accessibilityLabel("No results found")
                case .error(let message):
                    Text("\(Constants.error) \(message)")
                        .foregroundColor(.red)
                        .font(.headline)
                        .accessibilityLabel("Error: \(message)")
                        .padding()
                }
                Spacer()
            }
        }
        .navigationBarTitle(Constants.AppName, displayMode: .inline)
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            UINavigationBar.appearance().backgroundColor = UIColor.systemTeal
        }

        
    }
    
}
