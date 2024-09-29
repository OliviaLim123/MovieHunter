//
//  MovieDetailListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SwiftUI

struct MovieDetailListView: View {
    let movie: Movie
    @State private var isFavorite: Bool = false
    @Binding var selectedTrailerURL: URL?
    
    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                HStack {
//                    Text(movie.title)
//                        .font(.title)
//                        .padding(.horizontal)
//                        .fontWeight(.bold)
//                    //ADD THE HEART SYMBOL
//                    Spacer()
//                    Image(systemName: isFavorite ? "heart.fill" : "heart")
//                        .font(.system(size: 30))
//                }
//                MovieDetailImage (imageURL: movie.backdropURL)
//                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                    .listRowInsets(EdgeInsets())
                
        movieDescriptionSection.listRowSeparator(.visible)
        movieCastSection.listRowSeparator(.hidden)
        movieTrailerSection
    }
    private var movieDescriptionSection: some View {
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
    
    private var movieCastSection: some View {
        HStack (alignment: .top, spacing: 4) {
            if let cast = movie.cast, !cast.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Starring")
                        .font(.headline)
                    ForEach(cast.prefix(9)) { Text($0.name)}
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            if let crew = movie.crew, !crew.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    if let directors = movie.directors, !directors.isEmpty {
                        Text("Director(s)")
                            .font(.headline)
                        ForEach(directors.prefix(2)) { Text($0.name)}
                    }
                    
                    if let producers = movie.producers, !producers.isEmpty {
                        Text("Producer(s)")
                            .font(.headline)
                        ForEach(producers.prefix(2)) { Text($0.name)}
                    }
                    
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
    
    @ViewBuilder
    private var movieTrailerSection: some View {
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
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }
}
