//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import SwiftUI

@main
struct MyWeatherAppApp: App {
    // Coordinator property
    @StateObject private var coordinator = MainCoordinator(navigationController: UINavigationController())
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: coordinator)
                .onAppear {
                    coordinator.start()
                }
        }
    }
}
