//
//  MovieDetailImage.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 27/9/2024.
//

import SwiftUI

// MARK: MOVIEW DETAIL IMAGE
struct MovieDetailImage: View {
    
    // STATE OBJECT for image loader
    @StateObject private var imageLoader = ImageLoader()
    // PROPERTY for image url
    let imageURL: URL
    
    // BODY VIEW
    var body: some View {
        ZStack {
            // Background color
            Color.gray.opacity(0.3)
            // Display the image from image loader
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        // Once this view appears, it will load the image based on the image url
        .onAppear {
           imageLoader.loadImage(with: imageURL)
        }
    }
}
