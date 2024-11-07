//
//  WeatherInfoRow.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import SwiftUI

struct WeatherInfoRow: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Text(label)
                .bold()
                .leftAligned()
                .accessibilityLabel("\(label):")
            Text(value)
                .leftAligned()
                .accessibilityValue(value)
        }
    }
}
