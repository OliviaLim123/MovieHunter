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
    @State private var selectedTrailer: MovieVideo?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text(movie.title)
                        .font(.title)
                        .padding(.horizontal)
                        .fontWeight(.bold)
                    //ADD THE HEART SYMBOL
                    Spacer()
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 30))
                    Spacer()
                }
                MovieDetailImage (imageURL: movie.backdropURL)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowInsets(EdgeInsets())
                Text(movie.genreText)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                HStack {
                    Text("🗓️ \(movie.yearText)")
                    Text(" | 🕐 \(movie.durationText)")
                }
                .fontWeight(.bold)
                .padding(.horizontal)
                Divider()
                Spacer()
                Text(movie.overview)
                    .padding(.horizontal)
                HStack {
                    if !movie.ratingText.isEmpty {
                        Text(movie.ratingText)
                            .foregroundStyle(.yellow)
                            .padding(.top)
                    }
                    Text(movie.scoreText)
                        .padding(.top)
                }
                .padding(.horizontal)
            }
            Divider()
            
            HStack (alignment: .top, spacing: 4) {
                if movie.cast != nil && movie.cast!.count > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Starring")
                            .font(.headline)
                            .padding(.top)
                        if let castList = self.movie.cast {
                            ForEach(castList.prefix(9)) { cast in
                                        Text(cast.name)
                            }
                        } else {
                            Text("Cast information is not available.")
                        }
                        
                    }
                    .padding(.horizontal)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                if movie.crew != nil && movie.crew!.count > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        if movie.directors != nil && movie.directors!.count > 0 {
                            Text("Director(s)")
                                .font(.headline)
                                .padding(.top)
                            if let directors = self.movie.directors {
                                ForEach(directors.prefix(2)) { crew in
                                    Text(crew.name)
                                }
                            } else {
                                Text("Directors information is not available")
                            }
                        }
                        
                        if movie.producers != nil && movie.producers!.count > 0{
                            Text("Producer(s)")
                                .font(.headline)
                                .padding(.top)
                            if let producers = self.movie.producers {
                                ForEach(producers.prefix(2)) { crew in
                                    Text(crew.name)
                                }
                            } else {
                                Text("Producers information is not available")
                            }
                        }
                        
                        if movie.screenWriters != nil && movie.screenWriters!.count > 0{
                            Text("Screenwriter(s)")
                                .font(.headline)
                                .padding(.top)
                            if let writers = self.movie.screenWriters {
                                ForEach(writers.prefix(2)) { crew in
                                    Text(crew.name)
                                }
                            } else {
                                Text("Screenwriters information is not available")
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
            }
            Divider()
            
            if movie.youtubeTrailers != nil && movie.youtubeTrailers!.count > 0{
                Text("Trailers")
                    .font(.headline)
                if let trailers = self.movie.youtubeTrailers {
                    ForEach(trailers) { trailer in
                        Button {
                            self.selectedTrailer = trailer
                        } label: {
                            HStack {
                                Text(trailer.name)
                                Spacer()
                                Image(systemName: "play.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                } else {
                    Text("Trailers video is not available")
                }
            }
        }
        .sheet(item: self.$selectedTrailer) { trailer in
            if let url = trailer.youtubeURL {
                SafariView(url: url)
            } else {
                Text("Trailer URL is not available")
            }
        }
    }
}
