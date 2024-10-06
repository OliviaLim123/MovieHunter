//
//  EmptyPlaceholderView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SwiftUI

// MARK: EMPTY PLACEHOLDER VIEW
struct EmptyPlaceholderView: View {
    
    // PROPERTIES of Empty Placeholder View
    let text: String
    let image: Image?
    
    // BODY VIEW
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            
            // Display Image
            if let image = image {
                image
                    .imageScale(.large)
                    .font(.system(size: 52))
            }
            
            // Display text
            Text(text)
            Spacer()
        }
    }
}

// MARK: EMPTY PLACEHOLDER PREVIEW
#Preview {
    EmptyPlaceholderView(text: "No Movies", image: Image(systemName: "film"))
}
