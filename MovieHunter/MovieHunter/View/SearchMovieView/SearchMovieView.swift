//
//  SearchMovieView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import SwiftUI

// MARK: SEARCH MOVIE VIEW
struct SearchMovieView: View {
    
    // STATE OBJECT for view model
    @StateObject var movieSearchVM = MovieSearchViewModel()
    
    // STATE PROPERTIES of SearchMovieView
    @State var speechText: String = ""
    @State var isVoiceSearchActive = false
    
    // BODY VIEW
    var body: some View {
        VStack {
            HStack {
                // Display the search icon
                Image(systemName: "magnifyingglass")
                
                // Display the transcribed text field
                TranscribedTextFieldView(searchText: $speechText)
                    .onChange(of: speechText) {
                        // Bind speech text to the search query
                        movieSearchVM.query = speechText
                    }
            }
            .padding(.horizontal)
            Spacer()
            
            // Display the results list
            if !movieSearchVM.query.isEmpty {
                manualSearch
            } else {
                // ERROR HANDLING by showing the empty place holder
                EmptyPlaceholderView(text: "Search your favourite movie", image: Image(systemName: "magnifyingglass"))
            }
        }
        .navigationTitle("Search Movies")
    }
    
    // MANUAL SEARCH VIEW
    private var manualSearch: some View {
        List {
            ForEach(movieSearchVM.movies) { movie in
                // Navigates to the Movie Detail View
                NavigationLink(destination: MovieDetailView(movieId: movie.id, movieTitle: movie.title)) {
                    // Displaying the movie with Movie Row View
                    MovieRowView(movie: movie)
                        .padding(.vertical, 8)
                }
            }
        }
        .overlay(overlayView)
        // Once this view appears, it will start observing
        .onAppear {
            movieSearchVM.startObserve()
        }
        .listStyle(.plain)
    }
    
    // MARK: BRANCHING PREVIEW
    @ViewBuilder
    // OVERLAY VIEW
    private var overlayView: some View {
        switch movieSearchVM.phase {
        // EMPTY CASE
        case .empty:
            if movieSearchVM.trimmedQuery.isEmpty {
                EmptyPlaceholderView(text: "Search your favourite movie", image: Image(systemName: "magnifyingglass"))
            } else {
                // ERROR HANDLING by displaying progress view
                ProgressView()
            }
        
        // SUCCESS CASE
        case .success(let value) where value.isEmpty:
            EmptyPlaceholderView(text: "No results", image: Image(systemName: "film"))
        
        // FAILURE CASE
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: {
                Task {
                    // Retry to search again by the query
                    await movieSearchVM.search(query: movieSearchVM.query)
                }
            })
            
        // DEFAULT CASE
        default: EmptyView()
        }
    }
}

// MARK: MOVIE ROW VIEW
struct MovieRowView: View {
    
    // PROPERTY of MovieRowView
    let movie: Movie
    
    // BODY VIEW
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Display the movie tumbnail view
            MovieTumbnailView(movie: movie, thumbnailType: .poster(showTitle: false))
                .frame(width: 61, height: 92)
            VStack(alignment: .leading) {
                // Display the movie title
                Text(movie.title)
                    .font(.headline)
                // Display the release year
                Text(movie.yearText)
                    .font(.subheadline)
                Spacer()
                // Display the rating star
                Text(movie.ratingText)
                    .foregroundStyle(.yellow)
            }
        }
    }
}

// MARK: SEARCH MOVIE PREVIEW
#Preview {
    NavigationView {
        SearchMovieView()
    }
}
