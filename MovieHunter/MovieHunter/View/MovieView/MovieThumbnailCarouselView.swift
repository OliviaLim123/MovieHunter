//
//  MoviePosterListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 26/9/2024.
//

import SwiftUI

// MARK: MOVIE THUMBNAIL CAROUSEL VIEW
struct MovieThumbnailCarouselView: View {
    
    // PROPERTIES of Movie Thumbnail Carousel View
    let title: String
    let movies: [Movie]
    var thumbnailType: MovieThumbnailType = .poster()
    
    // BODY VIEW
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            // Display the title
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            // Display the scroll view for movie list horizontally
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach (self.movies) { movie in
                        // Navigates to the Movie Detail View once it is clicked by the user
                        NavigationLink(destination: MovieDetailView(movieId: movie.id, movieTitle: movie.title)) {
                            // Displaying the movie by utilising the Movie Thumbnail View
                            MovieTumbnailView(movie: movie, thumbnailType: thumbnailType)
                                .movieThumbnailViewFrame(thumbnailType: thumbnailType)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: VIEW PRIVATE EXTENSION
fileprivate extension View {
    
    // MARK: BRANCHING PREVIEW
    @ViewBuilder
    func movieThumbnailViewFrame(thumbnailType: MovieThumbnailType) -> some View {
        switch thumbnailType {
        case .poster:
            self.frame(width: 204, height: 306)
        case .backdrop:
            self
                .aspectRatio(16/9, contentMode: .fit)
                .frame(height: 160)
        }
    }
}

// MARK: POSTER THUMBNAIL CAROUSEL VIEW
#Preview {
    MovieThumbnailCarouselView(title: "Now Playing", movies: Movie.mockSamples, thumbnailType: .poster(showTitle: true))
}

// MARK: BACKDROP THUMBNAIL CAROUSEL VIEW
#Preview {
    MovieThumbnailCarouselView(title: "Upcoming", movies: Movie.mockSamples, thumbnailType: .backdrop)
}
