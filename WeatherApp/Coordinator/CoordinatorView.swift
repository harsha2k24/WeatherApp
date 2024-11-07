//
//  CoordinatorView.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import SwiftUI
import UIKit

struct CoordinatorView: UIViewControllerRepresentable {
    let coordinator: MainCoordinator

    func makeUIViewController(context: Context) -> UINavigationController {
        coordinator.navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No update logic needed for now
    }
}
