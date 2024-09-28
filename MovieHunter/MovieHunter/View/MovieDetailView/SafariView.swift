//
//  SafariView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: self.url)
        return safariVC
    }
}
