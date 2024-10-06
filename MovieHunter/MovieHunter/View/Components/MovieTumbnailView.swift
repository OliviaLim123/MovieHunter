//
//  MoviePosterView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 26/9/2024.
//

import SwiftUI

// MARK: MOVIE THUMBNAIL TYPE ENUM
enum MovieThumbnailType {
    
    // ENUM CASES
    case poster(showTitle: Bool = true)
    case backdrop
}

// MARK: MOVIE THUMBNAIL VIEW
struct MovieTumbnailView: View {
    
    // PROPERTIES of MovieThumbnailView
    let movie: Movie
    var thumbnailType: MovieThumbnailType = .poster()
    // STATE OBJECT PROPERTY for image loader
    @StateObject var imageLoader = ImageLoader()
    
    // BODY VIEW
    var body: some View {
        containerView
        .onAppear {
            switch thumbnailType {
            case .poster:
                self.imageLoader.loadImage(with: self.movie.posterURL)
            case .backdrop:
                self.imageLoader.loadImage(with: self.movie.backdropURL)
            }
        }
    }
    
    // MARK: BRANCING PREVIEW
    @ViewBuilder
    private var containerView: some View {
        // For the backdrop thumbnail type case
        if case .backdrop = thumbnailType {
            VStack(alignment: .leading, spacing: 8) {
                imageView
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(1)
            }
        } else {
            imageView
        }
    }
    
    // IMAGE VIEW for poster thumbnail type
    private var imageView: some View {
        ZStack {
            // Background of image
            Color.gray.opacity(0.3)
            // For the poster thumbnail type case
            if case .poster(let showTitle) = thumbnailType, showTitle {
                Text(movie.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .lineLimit(4)
            }
            // Load and display the image
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .layoutPriority(-1)
            }
        }
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}

// MARK: POSTER THUMBNAIL PREVIEW
#Preview {
    MovieTumbnailView(movie: Movie.mockSample, thumbnailType: .poster(showTitle: true))
        .frame(width: 204, height: 306 )
}

// MARK: BACKDROP THUMBNAIL PREVIEW
#Preview {
    MovieTumbnailView(movie: Movie.mockSample, thumbnailType: .backdrop)
        .aspectRatio(16/9, contentMode: .fit)
        .frame( height: 160)
}
