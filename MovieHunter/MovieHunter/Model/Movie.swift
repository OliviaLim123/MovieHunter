//
//  Movie.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import Foundation

// MARK: MOVIE RESPONSE
struct MovieResponse: Decodable {
    
    // PROPERTY of MovieResponse
    let results: [Movie]
}

// MARK: MOVIE MODEL
struct Movie: Decodable, Identifiable {
    
    // PROPERTIES of Movie
    let id: Int
    let title: String
    let backdropPath: String?
    let posterPath: String?
    let overview: String
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let releaseDate: String?
    let genres: [MovieGenre]?
    let credits: MovieCredit?
    let videos: MovieVideoResponse?
    
    // STATIC PRIVATE PROPERTY to format the year
    static private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    // STATIC PRIVATE PROPERTY to format movie duration in hour and minute
    static private var durationFormatter: DateComponentsFormatter  {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }
    
    // COMPUTE PROPERTY to return the backdrop url from API
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")")!
    }
    
    // COMPUTE PROPERTY to return the poster url from API
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
    
    // COMPUTE PROPERTY to get the first genre name
    var genreText: String {
        genres?.first?.name ?? "Unknown genre"
    }
    
    // COMPUTE PROPERTY to get the rating stars of movie
    var ratingText: String {
        let rating = Int(voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "★"
        }
        return ratingText
    }
    
    // COMPUTE PROPERTY to get the score of rating out of 10
    var scoreText: String {
        // ERROR HANDLING when there is no rating star
        guard ratingText.count > 0 else {
            return "No rating is available"
        }
        return "\(ratingText.count)/10"
    }
    
    // COMPUTE PROPERTY to get release year of the movie
    var yearText: String {
        // ERROR HANDLING when the release year is unknown
        guard let releaseDate = self.releaseDate, let date = Decoder.dateFormatter.date(from: releaseDate) else {
            return "Unknown release date"
        }
        return Movie.yearFormatter.string(from: date)
    }
    
    // COMPUTE PROPERTY to get the movie duration
    var durationText: String {
        // ERROR HANDLING when the movie duration is unknown
        guard let runtime = self.runtime, runtime > 0 else {
            return "Unknown duration"
        }
        return Movie.durationFormatter.string(from: TimeInterval(runtime) * 60) ?? "Unkown duration"
    }
    
    // COMPUTE PROPERTY to store the movie casts involved
    var cast: [MovieCast]? {
        credits?.cast
    }
    
    // COMPUTE PROPERTY to store the movie crews involved
    var crew: [MovieCrew]? {
        credits?.crew
    }
    
    // COMPUTE PROPERTY to store the movie directors
    var directors: [MovieCrew]? {
        crew?.filter { $0.job.lowercased() == "director" }
    }
    
    // COMPUTE PROPERTY to store the movie producers
    var producers: [MovieCrew]? {
        crew?.filter { $0.job.lowercased() == "producer" }
    }
    
    // COMPUTE PROPERTY to store the movie screen writers
    var screenWriters: [MovieCrew]? {
        crew?.filter { $0.job.lowercased() == "story" }
    }
    
    // COMPUTE PROPERTY to store the movie trailers YouTube URL
    var youtubeTrailers: [MovieVideo]? {
        videos?.results.filter { $0.youtubeURL != nil }
    }
}

// MARK: MOVIE GENRE
struct MovieGenre: Decodable {
    
    // PROPERTY of MovieGenre
    let name: String
}
        
// MARK: MOVIE EXTENSION
extension Movie {
    
    // COMPUTE PROPERTY to create an array of mock samples from the JSON file
    static var mockSamples: [Movie] {
        let response: MovieResponse? = try? Bundle.main.loadAndDecodeJSON(filename: "movie_list")
        return response!.results
    }
    
    // COMPUTE PROPERTY to create one movie sample (obtain the second movie of the array)
    static var mockSample: Movie {
        mockSamples[1]
    }
}

// MARK: BUNDLE EXTENSION
extension Bundle {
    
    // FUNCTION to load and decode the JSON file
    func loadAndDecodeJSON<D: Decodable>(filename: String) throws -> D? {
        // ERROR HANDLING
        guard let url = self.url(forResource: filename, withExtension: "json") else {
            return nil
        }
        let data = try Data(contentsOf: url)
        let jsonDecoder = Decoder.jsonDecoder
        let decodedModel = try jsonDecoder.decode(D.self, from: data)
        return decodedModel
    }
}

// MARK: MOVIE SECTION EXTENSION
extension MovieSection {
    
    // STATIC PROPERTY to return the shuffled movie samples
    static var stubs: [MovieSection] {
        let stubbedMovies = Movie.mockSamples
        return MovieListEndPoint.allCases.map {
            MovieSection(movies: stubbedMovies.shuffled(), endpoint: $0)
        }
    }
}
