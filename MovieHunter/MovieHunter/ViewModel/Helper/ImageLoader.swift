//
//  ImageLoader.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 26/9/2024.
//

import SwiftUI
import UIKit

// Shared imageCache
private let _imageCache = NSCache<AnyObject, AnyObject>()

// MARK: IMAGE LOADER
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
        let urlString = url.absoluteString
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            // Return cached image to reduce the API request
            self.image = imageFromCache
            // DEBUG
            print("Image loaded from cache.")
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
                    return
                }
                // Cache the loaded image
                self.imageCache.setObject(image, forKey: urlString as AnyObject)
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                    // DEBUG
                    print("Image successfully loaded from URL.")
                }
            } catch {
                // ERROR HANDLING
                print(error.localizedDescription)
            }
        }
    }
}
