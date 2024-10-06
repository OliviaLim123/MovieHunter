//
//  MovieDetailListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SwiftUI

// MARK: MOVIE DETAIL LIST VIEW
struct MovieDetailListView: View {
    
    // PROPERTY for Movie
    let movie: Movie
    // STATE PROPERTY
    @State private var isFavorite: Bool = false
    // BINDING PROPERTY
    @Binding var selectedTrailerURL: URL?
    
    // BODY VIEW
    var body: some View {
        movieDescriptionSection.listRowSeparator(.visible)
        movieCastSection.listRowSeparator(.hidden)
        movieTrailerSection
    }
    
    // MOVIE DESCRIPTION SECTION VIEW
    private var movieDescriptionSection: some View {
        // Display the genre, release year, movie duration, movie overview, and rating star
        VStack(alignment: .leading, spacing: 16) {
            Text(movie.genreText)
                .fontWeight(.bold)
            HStack {
                Text("🗓️ \(movie.yearText)")
                Text(" | 🕐 \(movie.durationText)")
            }
            .font(.headline)
            Text(movie.overview)
            HStack {
                if !movie.ratingText.isEmpty {
                    Text(movie.ratingText)
                        .foregroundStyle(.yellow)
                }
                Text(movie.scoreText)
            }
            .padding(.vertical)
        }
    }
    
    // MOVIE CAST SECTION VIEW
    private var movieCastSection: some View {
        HStack (alignment: .top, spacing: 4) {
            // Display 9 movie casts involved
            if let cast = movie.cast, !cast.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Starring")
                        .font(.headline)
                    ForEach(cast.prefix(9)) { Text($0.name)}
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            
            // Display movie crew information
            if let crew = movie.crew, !crew.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    // Display 2 directors of the movie
                    if let directors = movie.directors, !directors.isEmpty {
                        Text("Director(s)")
                            .font(.headline)
                        ForEach(directors.prefix(2)) { Text($0.name)}
                    }
                    // Display 2 producers of the movie
                    if let producers = movie.producers, !producers.isEmpty {
                        Text("Producer(s)")
                            .font(.headline)
                        ForEach(producers.prefix(2)) { Text($0.name)}
                    }
                    // Display 2 screen writers of the moview
                    if let screenWriters = movie.screenWriters, !screenWriters.isEmpty {
                        Text("Screenwriter(s)")
                            .font(.headline)
                        ForEach(screenWriters.prefix(2)) { Text($0.name)}
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical)
    }
    
    // MARK: BRANCHING PREVIEW
    @ViewBuilder
    // MOVIE TRAILER SECTION VIEW
    private var movieTrailerSection: some View {
        // Display the movie trailers with the YouTube URL
        if let trailers = movie.youtubeTrailers, !trailers.isEmpty {
            Text("Trailers")
                .font(.headline)
            ForEach(trailers) { trailer in
                Button {
                    guard let url = trailer.youtubeURL else { return }
                    selectedTrailerURL = url
                } label: {
                    HStack {
                        Text(trailer.name)
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }
}
