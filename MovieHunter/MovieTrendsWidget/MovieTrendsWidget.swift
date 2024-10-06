//
//  MovieTrendsWidget.swift
//  MovieTrendsWidget
//
//  Created by Olivia Gita Amanda Lim on 6/10/2024.
//

import WidgetKit
import SwiftUI
import Foundation

// MARK: MOVIE ENTRY MODEL
struct MovieEntry: TimelineEntry {
    let date: Date
    let movieTitle: String
    let movies: [Movie]
}

// MARK: NOW PLAYING PROVIDER
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

// MARK: MOVIE TRENDS WIDGET VIEW
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
            VStack {
                HStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("Now Playing")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(textColor)
                }
                
                
                HStack(alignment: .center, spacing: 5) {
                    ForEach(entry.movies.prefix(4)) { movie in
                        VStack {
                            // Create a new ImageLoader for each movie
                            ImageView(imageLoader: ImageLoader(), url: movie.posterURL)
                            Text(movie.title)
                                .font(.system(size: 8))
                                .lineLimit(1)
                                .foregroundColor(textColor)
                        }
                        .frame(width: 80)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

// MARK: MOVIE TRENDS WIDGET
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

// MARK: IMAGE VIEW
struct ImageView: View {
    @StateObject var imageLoader: ImageLoader
    let url: URL

    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 70, height: 100)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                
            } else {
                Color.gray // Placeholder for when the image is loading
                    .frame(width: 70, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    .overlay(
                        Image(systemName: "film")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.white)
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

// MARK: IMAGE LOADER
class ImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    @Published var isLoading = false
    
    var imageCache = NSCache<AnyObject, AnyObject>()
    
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

// MARK: MOVIE API MANAGER
class MovieAPIManager {
    
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

// MARK: MOVIE RESPONSE
struct MovieResponse: Decodable {
    let results: [Movie]
}

// MARK: MOVIE MODEL
struct Movie: Decodable, Identifiable {
    let id: Int
    let title: String
    let backdropPath: String?
    let posterPath: String?
    
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")")!
    }
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
}

// MARK: DECODER CLASS
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

// MARK: MOVIE LIST END POINT ENUM
enum MovieListEndPoint: String, CaseIterable, Identifiable {
    
    var id: String { rawValue }
    case nowPlaying = "now_playing"
    
    var description: String {
        switch self {
        case .nowPlaying: return "Now Playing"
        }
    }
}

// MARK: MOVIE ERROR ENUM
enum MovieError: Error, CustomNSError {
    case invalidEndpoint
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .invalidEndpoint: return "Invalid endpoint"
        case .invalidResponse: return "Invalid response"
        }
    }
    
    var errorUserInfo: [String:Any] {
        [NSLocalizedDescriptionKey: localizedDescription]
    }
}

