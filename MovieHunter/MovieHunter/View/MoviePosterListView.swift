//
//  MoviePosterListView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 26/9/2024.
//

import SwiftUI

struct MoviePosterListView: View {
    
    let title: String
    let movies: [Movie]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach (self.movies) { movie in
                        MoviePosterCardView(movie: movie)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    MoviePosterListView(title: "Now Playing", movies: Movie.mockSamples)
}
