//
//  MainCoordinator.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import Foundation
import UIKit
import SwiftUI

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}



class MainCoordinator: Coordinator, ObservableObject {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let weatherService = WeatherService()
        let weatherViewModel = WeatherViewModel(weatherService: weatherService)
        let weatherView = WeatherView(viewModel: weatherViewModel, coordinator: self)
        let hostingController = UIHostingController(rootView: weatherView)
        
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    // Optional: Add navigation functions for other views
    func showCityDetail(for city: String) {
        // Define detail navigation if needed
    }
}

