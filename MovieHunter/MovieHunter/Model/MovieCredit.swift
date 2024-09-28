//
//  MovieCredit.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import Foundation

struct MovieCredit : Decodable {
    let cast : [MovieCast]
    let crew : [MovieCrew]
}

struct MovieCast: Decodable, Identifiable {
    let id: Int
    let character: String
    let name: String
}

struct MovieCrew: Decodable, Identifiable {
    let id: Int
    let job: String
    let name: String
}
