//
//  LeftAlignedText.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import Foundation
import SwiftUI
// ViewModifier Reusability: The LeftAlignedText can be reused across different views, making your code cleaner and more modular.

struct LeftAlignedText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func leftAligned() -> some View {
        self.modifier(LeftAlignedText())
    }
}
