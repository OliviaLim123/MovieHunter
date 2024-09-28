//
//  LoadingView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 28/9/2024.
//

import SwiftUI
import ActivityIndicatorView

struct LoadingView: View {
    let isLoading: Bool
    let error: NSError?
    let retryAction: (() -> ())?
    
    var body: some View {
        Group {
            if isLoading {
                HStack {
                    Spacer()
                    ActivityIndicatorView()
                        .frame(width:100, height:100)
                    Spacer()
                }
            } else if error != nil {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text(error!.localizedDescription)
                            .font(.headline)
                        if self.retryAction != nil {
                            Button(action: self.retryAction!) {
                                Text("Retry..")
                            }
                            .foregroundColor(.blue)
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    LoadingView(isLoading: true, error: nil, retryAction: nil)
}
