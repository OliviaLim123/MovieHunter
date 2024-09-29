//
//  SearchMovieView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

struct SearchMovieView: View {
    @StateObject var movieSearchVM = MovieSearchViewModel()
    @State var speechText: String = ""
    @State private var isVoiceSearchActive = false
    
    var body: some View {
        VStack {
            
                    // Switch between manual search and voice search
                    if isVoiceSearchActive {
                        TranscribedTextFieldView(searchText: $speechText)
                            .onChange(of: speechText) { newValue in
                                movieSearchVM.query = newValue // Bind speech text to the search query
                            }
                            .padding(.horizontal)
                    } else {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                
                            TextField("Type the movie title", text: $movieSearchVM.query)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    // Trigger search when the user submits the query manually
                                    Task {
                                        await movieSearchVM.search(query: movieSearchVM.query)
                                    }
                                }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Buttons to toggle between search modes
                    HStack {
                        Button(action: {
                            isVoiceSearchActive = false // Manual search
                        }) {
                            Text("Search manually")
                                .foregroundColor(isVoiceSearchActive ? .gray : .blue)
                                .padding()
                        }
                        .disabled(!isVoiceSearchActive) // Disable if already in manual mode

                        Button(action: {
                            isVoiceSearchActive = true // Voice search
                        }) {
                            Text("Search with voice")
                                .foregroundColor(isVoiceSearchActive ? .blue : .gray)
                                .padding()
                        }
                        .disabled(isVoiceSearchActive) // Disable if already in voice mode
                    }

                    Spacer()

                    // Results list
                    if !movieSearchVM.query.isEmpty {
                        manualSearch
                    } else {
                        EmptyPlaceholderView(text: "Search your favourite movie", image: Image(systemName: "magnifyingglass"))
                    }
                }
                .navigationTitle("Search Movies")
    }
    
    private var manualSearch: some View {
        List {
            ForEach(movieSearchVM.movies) { movie in
                NavigationLink(destination: MovieDetailView(movieId: movie.id, movieTitle: movie.title)) {
                    MovieRowView(movie: movie)
                        .padding(.vertical, 8)
                }
            }
        }
//        .searchable(text: $movieSearchVM.query, prompt: "Search movies")
        .overlay(overlayView)
        .onAppear {
            movieSearchVM.startObserve()
        }
        .listStyle(.plain)
    }
    @ViewBuilder
    private var overlayView: some View {
        switch movieSearchVM.phase {
        case .empty:
            if movieSearchVM.trimmedQuery.isEmpty {
                EmptyPlaceholderView(text: "Search your favourite movie", image: Image(systemName: "magnifyingglass"))
            } else {
                ProgressView()
            }
            
        case .success(let value) where value.isEmpty:
            EmptyPlaceholderView(text: "No results", image: Image(systemName: "film"))
            
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: {
                Task {
                    await movieSearchVM.search(query: movieSearchVM.query)
                }
            })
        default: EmptyView()
        }
    }
}

struct MovieRowView: View {
    let movie: Movie
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            MovieTumbnailView(movie: movie, thumbnailType: .poster(showTitle: false))
                .frame(width: 61, height: 92)
            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                Text(movie.yearText)
                    .font(.subheadline)
                Spacer()
                Text(movie.ratingText)
                    .foregroundStyle(.yellow)
            }
        }
    }
}

#Preview {
    NavigationView {
        SearchMovieView()
    }
}
