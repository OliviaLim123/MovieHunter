//
//  BottomSheetView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import SwiftUI

// MARK: BOTTOM SHEET VIEW
struct SwiftUIView: View {
    
    // STATE OBJECT of Speach Recogniser
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    // BINDINGS PROPERTIES
    @Binding var isRecording:Bool
    @Binding var searchText:String
    @Binding var color:Color
    
    // BODY VIEW
    var body: some View {
        VStack{
            Spacer()
            // Display the text if isRecording is true, otherwise empty string
            Text(isRecording ? (speechRecognizer.transcript.isEmpty ? "Speak Now" : speechRecognizer.transcript) : "")
                .frame(width: 300, height: 200, alignment: .center)
            
            Spacer()
            // Display the lottie animation of voice recording
            LottieView(name: Constants.voiceAnimation, loopMode: .loop, animationSpeed: 1.0, retryAction: {})
            
            Spacer()
            // Button to stop the recording
            Button {
                speechRecognizer.stopTranscribing()
                searchText = speechRecognizer.transcript
                isRecording = false
            } label: {
                Text("Stop recording to search the movie")
                    .foregroundColor(.blue)
                    .padding()
            }
            Spacer()
        }
        .onAppear {
            // Start transcribe the voice when the view appears
            speechRecognizer.transcribe()
            color = .red
        }
        .onDisappear {
            // Stop transcribe the voice when the view disappear
            color = .gray
            speechRecognizer.stopTranscribing()
        }
        .onChange(of: speechRecognizer.hasStoppedRecording) {
            // Automatically perform search when the recording has stopped
            if speechRecognizer.hasStoppedRecording {
                searchText = speechRecognizer.transcript
                isRecording = false
            }
        }
    }
}
