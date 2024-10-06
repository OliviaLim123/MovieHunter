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
    
    // PROPERTIES of Movie Entery
    let date: Date
    let movieTitle: String
    let movies: [Movie]
}

// MARK: NOW PLAYING PROVIDER
struct NowPlayingProvider: TimelineProvider {
    
    // FUNCTION for placeholder data when the widget is loading
    func placeholder(in context: Context) -> MovieEntry {
        MovieEntry(date: Date(), movieTitle: "Loading...", movies: [])
    }

    // FUNCTION that provides a snapshot for quick display in widget
    func getSnapshot(in context: Context, completion: @escaping (MovieEntry) -> Void) {
        let entry = MovieEntry(date: Date(), movieTitle: "Snapshot", movies: [])
        completion(entry)
    }

    // FUNCTION to provide the timeline entries for the widget (when the data is available)
    func getTimeline(in context: Context, completion: @escaping (Timeline<MovieEntry>) -> Void) {
        Task {
            do {
                // Fetch "now playing" movies from API
                let movies = try await MovieAPIManager.shared.fetchMovies(from: .nowPlaying)
                let entryDate = Date()
                // Create the entry with the fetched movies
                let entry = MovieEntry(date: entryDate, movieTitle: movies.first?.title ?? "No Movies", movies: movies)
                // Refresh the widget every hour
                let timeline = Timeline(entries: [entry], policy: .after(entryDate.addingTimeInterval(60 * 60)))
                completion(timeline)
            } catch {
                // DEBUG
                print("Failed to fetch movies: \(error.localizedDescription)")
                // ERROR HANDLING by showing a fallback entry
                let entry = MovieEntry(date: Date(), movieTitle: "Error fetching movies", movies: [])
                let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 60)))
                completion(timeline)
            }
        }
    }
}

// MARK: MOVIE TRENDS WIDGET VIEW
struct MovieTrendsWidgetEntryView: View {
    
    // PROPERTY widget entry data
    var entry: NowPlayingProvider.Entry
    // COMPUTE PROPERTY to get the current hour for determining the day or night mode
    var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }
    // COMPUTE PROPERTY to toggle between day or night mode based on the time of day
    var isNightMode: Bool {
        currentHour < 6 || currentHour >= 18
    }
    // COMPUTE PROPERTY for background colour based on the time of day
    var backgroundColor: Color {
        isNightMode ? .black : .white
    }
    // COMPUTE PROPERTY for text colour based on the time of day
    var textColor: Color {
        isNightMode ? .white : .black
    }

    // BODY VIEW
    var body: some View {
        ZStack {
            // Set the background for the widget container
            ContainerRelativeShape()
                .inset(by: -17)
                .fill(backgroundColor)
            
            VStack {
                // Header of the widget (App logo and title)
                HStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("Now Playing")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(textColor)
                }
                
                // Display up to four movies in the widget
                HStack(alignment: .center, spacing: 5) {
                    ForEach(entry.movies.prefix(4)) { movie in
                        // Image loader for each movie
                        let imageLoader = ImageLoader()
                        VStack {
                            // Show the movie poster along with its title
                            ImageView(imageLoader: imageLoader, url: movie.posterURL)
                            
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
    
    // PROPERTY of MovieTrendsWidget
    let kind: String = "MovieTrendsWidget"

    // WIDGET CONFIGURATION BODY
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NowPlayingProvider()) { entry in
            // Adjust UI for iOS 17.0 and above with the proper settings
            if #available(iOS 17.0, *) {
                MovieTrendsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MovieTrendsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        // Display the widget name and description
        .configurationDisplayName("Movie Trends Widget")
        .description("Showing four now playing movies.")
    }
}

// MARK: IMAGE VIEW
struct ImageView: View {
    
    // STATE OBJECT of ImageLoader
    @StateObject var imageLoader: ImageLoader
    // PROPERTY for image url
    let url: URL
    
    // BODY VIEW
    var body: some View {
        Group {
            if let image = imageLoader.image {
                // Show the movie poster if loaded
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 70, height: 100)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
            } else {
                // Show the placeholder when the image is not yet loaded
                Color.gray
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
            // Load image when the view appears
            imageLoader.loadImage(with: url)
        }
        // Ensure that the image doesn't overflow its frame
        .clipped()
    }
}

// MARK: IMAGE LOADER
// Shared imageCache
private let _imageCache = NSCache<AnyObject, AnyObject>()
class ImageLoader: ObservableObject {
    
    // PUBLISHED PROPERTIES of ImageLoader
    @Published var image: UIImage?
    @Published var isLoading = false
    
    // PROPERTY for storing the loaded images
    var imageCache = _imageCache
    
    // METHOD to load the image from an url
    func loadImage(with url: URL) {
        // DEBUG
        print("Loading image from URL: \(url)")
        isLoading = true
        let urlString = url.absoluteString
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            // Return cached image to reduce the API request
            self.image = imageFromCache
            // DEBUG
            print("Image loaded from cache.")
            isLoading = false
            return
        }

        // Load the image asynchronously if not cached
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            do {
                // ERROR HANDLING if the image is failed to load
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    // DEBUG
                    print("Failed to convert data to image.")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                // Cache the loaded image
                self.imageCache.setObject(image, forKey: urlString as AnyObject)
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                    self?.isLoading = false
                    // DEBUG
                    print("Image successfully loaded from URL.")
                }
            } catch {
                // ERROR HANDLING
                DispatchQueue.main.async {
                    self.isLoading = false
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: MOVIE API MANAGER
class MovieAPIManager {
    
    // STATIC PROPERTY
    static let shared = MovieAPIManager()
    private init() {}
    // PROPERTIES for API
    private let apiKey = "0d9467472a2bed765450187cee11d8ff"
    private let baseAPIURL = "https://api.themoviedb.org/3"
    private let urlSession = URLSession.shared
    private let jsonDecoder = Decoder.jsonDecoder
    
    // METHOD for fetching movies from the given endpoint
    func fetchMovies(from endpoint: MovieListEndPoint) async throws -> [Movie] {
        // ERROR HANDLING if the endpoint is invalid
        guard let url = URL(string: "\(baseAPIURL)/movie/\(endpoint.rawValue)") else {
            throw MovieError.invalidEndpoint
        }
        let movieResponse: MovieResponse = try await self.loadURLAndDecode(url: url)
        return movieResponse.results
    }
    
    // PRIVATE METHOD for loading and decoding the JSON data from URL
    private func loadURLAndDecode<D: Decodable>(url: URL, params: [String: String]? = nil) async throws -> D {
        // ERROR HANDLING if the endpoint is invalid
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw MovieError.invalidEndpoint
        }
        // Appending the query items
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        urlComponents.queryItems = queryItems
        // ERROR HANDLING if the endpoint is invalid
        guard let finalURL = urlComponents.url else {
            throw MovieError.invalidEndpoint
        }
        let (data, response) = try await urlSession.data(from: finalURL)
        // ERROR HANDLING if the http response is invalid
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw MovieError.invalidResponse
        }
        // Return decoded data
        return try self.jsonDecoder.decode(D.self, from: data)
    }
}

// MARK: MOVIE RESPONSE
struct MovieResponse: Decodable {
    
    // PROPERTY of MovieReponse
    let results: [Movie]
}

// MARK: MOVIE MODEL
struct Movie: Decodable, Identifiable {
    
    // PROPERTIES of Movie
    let id: Int
    let title: String
    let backdropPath: String?
    let posterPath: String?
    
    // COMPUTE PROPERTY to return the backdrop url from API
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")")!
    }
    // COMPUTE PROPERTY to return the poster url from API
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
}

// MARK: DECODER CLASS
class Decoder {
    
    // JSON decoder static property
    static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    // DATE decoder static property (Format: year-month-day)
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return dateFormatter
    }()
}

// MARK: MOVIE LIST END POINT ENUM
enum MovieListEndPoint: String, CaseIterable, Identifiable {
    
    // PROPERTIES of MovieListEndPoint
    var id: String { rawValue }
    case nowPlaying = "now_playing"
    
    // COMPUTE PROPERTY for description
    var description: String {
        switch self {
        case .nowPlaying: return "Now Playing"
        }
    }
}

// MARK: MOVIE ERROR ENUM
enum MovieError: Error, CustomNSError {
    
    // ENUM CASES of MovieError
    case invalidEndpoint
    case invalidResponse
    
    // COMPUTE PROPERTY for localisedDescription in each error case
    var localizedDescription: String {
        switch self {
        case .invalidEndpoint: return "Invalid endpoint"
        case .invalidResponse: return "Invalid response"
        }
    }
    
    // COMPUTE PROPERTY for error user info
    var errorUserInfo: [String:Any] {
        [NSLocalizedDescriptionKey: localizedDescription]
    }
}
