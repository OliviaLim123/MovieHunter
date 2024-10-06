//
//  RetryView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SwiftUI

// MARK: RETRY VIEW
struct RetryView: View {
    
    // PROPERTIES of RetryView
    let text: String
    let retryAction: () -> ()
    
    // BODY VIEW
    var body: some View {
        VStack(spacing: 8) {
            // Display text
            Text(text)
                .font(.callout)
                .multilineTextAlignment(.center)
            
            // Button to try again
            Button(action: retryAction) {
                Text("Try Again")
            }
        }
    }
}

// MARK: RETRY PREVIEW
#Preview {
    RetryView(text: "An Error occured") {
        // DEBUG
        print("Retry Tapped")
    }
}
