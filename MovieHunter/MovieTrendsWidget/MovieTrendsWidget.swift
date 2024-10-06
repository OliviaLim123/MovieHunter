//
//  MovieTrendsWidget.swift
//  MovieTrendsWidget
//
//  Created by Olivia Gita Amanda Lim on 6/10/2024.
//

import WidgetKit
import SwiftUI

struct NowPlayingProvider: TimelineProvider {
    func placeholder(in context: Context) -> MovieEntry {
        MovieEntry(date: Date(), movieTitle: "Loading...", movies: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (MovieEntry) -> Void) {
        let entry = MovieEntry(date: Date(), movieTitle: "Snapshot", movies: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MovieEntry>) -> Void) {
        Task {
            do {
                let movies = try await MovieAPIManager.shared.fetchMovies(from: .nowPlaying) // Fetch now playing movies
                let entryDate = Date()
                let entry = MovieEntry(date: entryDate, movieTitle: movies.first?.title ?? "No Movies", movies: movies)
                let timeline = Timeline(entries: [entry], policy: .after(entryDate.addingTimeInterval(60 * 60)))
                completion(timeline)
            } catch {
                print("Failed to fetch movies: \(error.localizedDescription)")
                let entry = MovieEntry(date: Date(), movieTitle: "Error fetching movies", movies: [])
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 60)))
                completion(timeline)
            }
        }
    }
}

struct MovieEntry: TimelineEntry {
    let date: Date
    let movieTitle: String
    let movies: [Movie]
}

struct ImageView: View {
    @StateObject var imageLoader: ImageLoader
    let url: URL

    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 100, height: 150)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                
            } else {
                Color.gray // Placeholder for when the image is loading
                    .frame(width: 100, height: 150)
                    .overlay(
                        Image(systemName: "film")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    )
            }
        }
        .onAppear {
            // Load image only once when the view appears
            imageLoader.loadImage(with: url)
        }
        .clipped() // Ensure that the image doesn't overflow its frame
    }
}


struct MovieTrendsWidgetEntryView: View {
    var entry: NowPlayingProvider.Entry
    @StateObject var imageLoader = ImageLoader()
    var currentHour: Int {
            Calendar.current.component(.hour, from: Date())
        }
        
        // Determine if the current mode should be light or dark based on time
        var isNightMode: Bool {
            currentHour < 6 || currentHour >= 18
        }
        
        // Define background color based on time of day
        var backgroundColor: Color {
            isNightMode ? .black : .white
        }
        
        // Define text color based on time of day
        var textColor: Color {
            isNightMode ? .white : .black
        }

        

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .inset(by: -17)
                .fill(backgroundColor)
            HStack {
                // Background image filling the entire widget
                if let topMovie = entry.movies.first {
                    ImageView(imageLoader: imageLoader, url: topMovie.posterURL)
                }

                // Overlay text on top of the image
                VStack(alignment: .leading) {
                    HStack {
                        Image("logo")
                            .resizable()
                            .frame(width:40, height:40)
                            .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        Text("Now Playing")
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundStyle(textColor)
                    }
                    .padding(.bottom, 5)

                    if let topMovie = entry.movies.first {
                        Text(topMovie.title)
                            .font(.subheadline)
                            .lineLimit(1)
                            .padding(.bottom, 5)
                            .foregroundStyle(textColor)
                    } else {
                        Text("No Movies Available")
                            .font(.subheadline)
                            .padding(.bottom, 5)
                            .foregroundStyle(textColor)
                    }
                    
                    if let topMovie = entry.movies.first {
                        Text("🗓️ \(topMovie.yearText)")
                            .font(.caption)
                            .foregroundStyle(textColor)
                        Text(topMovie.ratingText)
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 10) // Padding for the text overlay
            }
        }
    }
}



struct MovieTrendsWidget: Widget {
    let kind: String = "MovieTrendsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NowPlayingProvider()) { entry in
            if #available(iOS 17.0, *) {
                MovieTrendsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MovieTrendsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
import Foundation
//API KEY: 0d9467472a2bed765450187cee11d8ff

class MovieAPIManager: MovieService {
    
    static let shared = MovieAPIManager()
    private init() {}
    
    private let apiKey = "0d9467472a2bed765450187cee11d8ff"
    private let baseAPIURL = "https://api.themoviedb.org/3"
    private let urlSession = URLSession.shared
    private let jsonDecoder = Decoder.jsonDecoder
    
    func fetchMovies(from endpoint: MovieListEndPoint) async throws -> [Movie] {
        guard let url = URL(string: "\(baseAPIURL)/movie/\(endpoint.rawValue)") else {
            throw MovieError.invalidEndpoint
        }
        let movieResponse: MovieResponse = try await self.loadURLAndDecode(url: url)
        return movieResponse.results
    }
    
    func fetchMovie(id: Int) async throws -> Movie {
        guard let url = URL(string: "\(baseAPIURL)/movie/\(id)") else {
            throw MovieError.invalidEndpoint
        }
        return try await self.loadURLAndDecode(url: url, params: [ "append_to_response" : "videos,credits"])
    }
    
    func searchMovie(query: String) async throws -> [Movie] {
        guard let url = URL(string: "\(baseAPIURL)/search/movie") else {
            throw MovieError.invalidEndpoint
        }
        let movieResponse: MovieResponse = try await self.loadURLAndDecode(url: url, params: [
            "language" : "en-US",
            "include_adult" : "false",
            "region" : "US",
            "query" : query
            ])
        return movieResponse.results
    }
    
    private func loadURLAndDecode<D: Decodable>(url: URL, params: [String: String]? = nil) async throws -> D {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw MovieError.invalidEndpoint
        }
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        urlComponents.queryItems = queryItems
        guard let finalURL = urlComponents.url else {
            throw MovieError.invalidEndpoint
        }
        
        let (data, response) = try await urlSession.data(from: finalURL)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MovieError.invalidResponse
        }
        return try self.jsonDecoder.decode(D.self, from: data)
        
    }
}

import Foundation

struct MovieResponse: Decodable {
    let results: [Movie]
}

struct Movie: Decodable, Identifiable {
    let id: Int
    let title: String
    let voteAverage: Double
    let backdropPath: String?
    let posterPath: String?
    let releaseDate: String?
    
    static private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")")!
    }
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
    
    var ratingText: String {
        let rating = Int(voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "★"
        }
        return ratingText
    }
    var yearText: String {
        guard let releaseDate = self.releaseDate, let date = Decoder.dateFormatter.date(from: releaseDate) else {
            return "Unknown release date"
        }
        return Movie.yearFormatter.string(from: date)
    }
}
   
class Decoder {
    static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return dateFormatter
    }()
}

private let _imageCache = NSCache<AnyObject, AnyObject>()

class ImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    @Published var isLoading = false
    
    var imageCache = _imageCache
    
    func loadImage(with url: URL) {
        print("Loading image from URL: \(url)")
        let urlString = url.absoluteString
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            print("Image loaded from cache.")
            return
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    print("Failed to convert data to image.")
                    return
                }
                self.imageCache.setObject(image, forKey: urlString as AnyObject)
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                    print("Image successfully loaded from URL.")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
import Foundation

protocol MovieService {
    func fetchMovies(from endpoint: MovieListEndPoint) async throws -> [Movie]
    func fetchMovie(id: Int) async throws -> Movie
    func searchMovie(query: String) async throws -> [Movie]
}

enum MovieListEndPoint: String, CaseIterable, Identifiable {
    
    var id: String { rawValue }
    
    case nowPlaying = "now_playing"
    case upcoming
    case topRated = "top_rated"
    case popular
    
    var description: String {
        switch self {
        case .nowPlaying: return "Now Playing"
        case .upcoming: return "Upcoming"
        case .topRated: return "Top Rated"
        case .popular: return "Popular"
        }
    }
}

enum MovieError: Error, CustomNSError {
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
    
    var localizedDescription: String {
        switch self {
        case .apiError: return "Failed to fetch data"
        case .invalidEndpoint: return "Invalid endpoint"
        case .invalidResponse: return "Invalid response"
        case .noData: return "No data"
        case .serializationError: return "Failed to decode data"
        }
    }
    
    var errorUserInfo: [String:Any] {
        [NSLocalizedDescriptionKey: localizedDescription]
    }
}

