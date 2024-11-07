//
//  SearchBar.swift
//  WeatherApp
//
//  Created by Harsha on 11/07/24.
//

import SwiftUI

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField(Constants.searchPlaceHolder, text: $text)
                .padding(6)
                .cornerRadius(Constants.viewCornerRadius)
                .padding(.leading,Constants.viewCornerRadius)
                .autocorrectionDisabled(true) // Disable autocorrection
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing, Constants.viewCornerRadius)
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .cornerRadius(Constants.viewCornerRadius)
        .padding(.horizontal)
    }
}

