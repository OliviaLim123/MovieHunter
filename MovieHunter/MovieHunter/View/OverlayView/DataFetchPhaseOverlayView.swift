//
//  DataFetchPhaseOverlayView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SwiftUI

// MARK: EMPTY DATA PROTOCOL
protocol EmptyData {
    var isEmpty: Bool { get }
}

// MARK: DATA FETCH PHASE OVERLAY VIEW
struct DataFetchPhaseOverlayView<V: EmptyData>: View {
    
    // PROPERTIES for phase and retry action
    let phase: DataFetchPhase<V>
    let retryAction: () -> ()
    
    // BODY VIEW
    var body: some View {
        // Display the proper view for each case
        switch phase {
        case .empty:
            ProgressView()
        case .success(let value) where value.isEmpty:
            EmptyPlaceholderView(text: "No data", image: Image(systemName: "film"))
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: retryAction)
        default:
            EmptyView()
        }
    }
}

// MARK: ARRAY EXTENSION
extension Array: EmptyData {}

// MARK: OPTIONAL EXTENSION
extension Optional: EmptyData {
    // COMPUTE PROPERTY for case .none
    var isEmpty: Bool {
        if case .none = self {
            return true
        }
        return false
    }
}

// MARK: SUCCESS OVERLAY PREVIEW
#Preview {
    DataFetchPhaseOverlayView(phase: .success([])) {
        // DEBUG
        print("Retry")
    }
}

// MARK: EMPTY OVERLAY PREVIEW
#Preview {
    DataFetchPhaseOverlayView<[Movie]>(phase: .empty) {
        // DEBUG
        print("Retry")
    }
}

// MARK: FAILURE OVERLAY PREVIEW
#Preview {
    DataFetchPhaseOverlayView<Movie?>(phase: .failure(MovieError.invalidResponse)) {
        // DEBUG
        print("Retry")
    }
}
