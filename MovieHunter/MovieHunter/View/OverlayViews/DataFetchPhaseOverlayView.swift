//
//  DataFetchPhaseOverlayView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SwiftUI

protocol EmptyData {
    var isEmpty: Bool { get }
}

struct DataFetchPhaseOverlayView<V: EmptyData>: View {
    let phase: DataFetchPhase<V>
    let retryAction: () -> ()
    
    var body: some View {
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
extension Array: EmptyData {}
extension Optional: EmptyData {
    var isEmpty: Bool{
        if case .none = self {
            return true
        }
        return false
    }
}

#Preview {
    DataFetchPhaseOverlayView(phase: .success([])) {
        print("Retry")
    }
}
#Preview {
    DataFetchPhaseOverlayView<[Movie]>(phase: .empty) {
        print("Retry")
    }
}
#Preview {
    DataFetchPhaseOverlayView<Movie?>(phase: .failure(MovieError.invalidResponse)) {
        print("Retry")
    }
}
