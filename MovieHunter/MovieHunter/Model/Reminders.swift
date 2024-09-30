//
//  Reminders.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import Foundation

struct Reminders: Identifiable {
    let id = UUID() // Unique identifier for each reminder
    let movieId: Int
    let movieTitle: String
    let date: Date
}
