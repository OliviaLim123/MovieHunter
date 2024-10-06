//
//  Decoder.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 23/9/2024.
//

import Foundation

// MARK: DECODER CLASS
class Decoder {
    
    // STATIC PROPERTY to decode JSON
    static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    // STATIC PROPERTY to decode date (Format: year-month-day)
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return dateFormatter
    }()
}
