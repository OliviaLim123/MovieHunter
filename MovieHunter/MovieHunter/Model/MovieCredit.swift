//
//  MovieCredit.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import Foundation

// MARK: MOVIE CREDIT
struct MovieCredit : Decodable {
    
    // PROPERTIES of Movie Credit
    let cast : [MovieCast]
    let crew : [MovieCrew]
}

// MARK: MOVIE CAST
struct MovieCast: Decodable, Identifiable {
    
    // PROPERTIES of MovieCast
    let id: Int
    let character: String
    let name: String
}

// MARK: MOVIE CREW
struct MovieCrew: Decodable, Identifiable {
    
    // PROPERTIES of MovieCrew
    let id: Int
    let job: String
    let name: String
}
