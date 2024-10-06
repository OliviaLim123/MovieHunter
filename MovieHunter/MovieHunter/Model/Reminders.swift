//
//  Reminders.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 30/9/2024.
//

import Foundation

// MARK: REMINDERS MODEL
struct Reminders: Identifiable {
    
    // PROPERTIES of Reminders
    let id = UUID() 
    let movieId: Int
    let movieTitle: String
    let date: Date
}
