//
//  SafariView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SafariServices
import SwiftUI

// MARK: SAFARI VIEW
struct SafariView: UIViewControllerRepresentable {
    
    // PROPERTY for url
    let url: URL
    
    // FUNCTION to update UI view, in this case, the body is empty
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
    
    // FUNCTION to make UI view controller 
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: self.url)
        return safariVC
    }
}
