//
//  MoviePosterView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 26/9/2024.
//

import SwiftUI

struct MoviePosterCardView: View {
    let movie: Movie
    @ObservedObject var imageLoader = ImageLoader()
    
    var body: some View {
        ZStack {
            if self.imageLoader.image != nil {
                Image(uiImage: self.imageLoader.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .shadow(radius: 4)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                VStack {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 100, height: 80)
                        .foregroundStyle(.white)
                        .padding()
                    Text(movie.title)
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                }
            }
        }
        .frame(width: 204, height: 306)
        .onAppear {
            self.imageLoader.loadImage(with: self.movie.posterURL)
        }
    }
}

#Preview {
    MoviePosterCardView(movie: Movie.mockSample)
}
