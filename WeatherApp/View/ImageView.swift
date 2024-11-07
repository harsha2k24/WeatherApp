//
//  ImageView.swift
//  WeatherApp
//
//  Created by Harsha on 11/06/24.
//

import SwiftUI

struct ImageView: View {
    let url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                    .cornerRadius(Constants.viewCornerRadius)
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .cornerRadius(Constants.viewCornerRadius)
            @unknown default:
                EmptyView()
            }
        }
    }
}
