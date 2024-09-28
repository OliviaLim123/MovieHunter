//
//  MoviePosterView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 26/9/2024.
//

import SwiftUI

enum MovieThumbnailType {
    case poster(showTitle: Bool = true)
    case backdrop
}

struct MovieTumbnailView: View {
    let movie: Movie
    var thumbnailType: MovieThumbnailType = .poster()
    @StateObject var imageLoader = ImageLoader()
    
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
    
    @ViewBuilder // Brancing Preview
    private var containerView: some View {
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
    
    private var imageView: some View {
        ZStack{
            Color.gray.opacity(0.3)
            
            if case .poster(let showTitle) = thumbnailType, showTitle {
                Text(movie.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .lineLimit(4)
            }
            
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

#Preview {
    MovieTumbnailView(movie: Movie.mockSample, thumbnailType: .poster(showTitle: true))
        .frame(width: 204, height: 306 )
}
#Preview {
    MovieTumbnailView(movie: Movie.mockSample, thumbnailType: .backdrop)
        .aspectRatio(16/9, contentMode: .fit)
        .frame( height: 160)
}
