//
//  MovieDetailImage.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 27/9/2024.
//

import SwiftUI

struct MovieDetailImage: View {
    
    @StateObject private var imageLoader = ImageLoader()
    let imageURL: URL
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .onAppear {
           imageLoader.loadImage(with: imageURL)
        }
    }
}
