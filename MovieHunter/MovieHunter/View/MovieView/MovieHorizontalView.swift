//
//  MovieHorizontalView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 26/9/2024.
//

//import SwiftUI
//
//struct MovieHorizontalView: View {
//    let title: String
//    let movies: [Movie]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0){
//            Text(title)
//                .font(.title)
//                .fontWeight(.bold)
//                .padding(.horizontal)
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(alignment: .top, spacing: 16) {
//                    ForEach(self.movies) { movie in
//                        NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
//                            MovieTumbnailView(movie: movie)
//                                .frame(width: 272, height: 200)
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//}
//
//#Preview {
//    MovieHorizontalView(title: "UpComing", movies: Movie.mockSamples)
//}
