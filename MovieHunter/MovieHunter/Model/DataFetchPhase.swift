//
//  DataFetchPhase.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import Foundation

// MARK: DATA FETCH PHASE
enum DataFetchPhase<V> {
    
    // ENUM CASES of DataFetchPhse
    case empty
    case success(V)
    case failure(Error)
    
    // COMPUTE PROPERTY for success value
    var value: V? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
}
