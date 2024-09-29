//
//  BottomSheetView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import SwiftUI

//Bottom Sheet
struct SwiftUIView: View {
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var isRecording:Bool
    @Binding var searchText:String
    @Binding var color:Color
    var body: some View {
        VStack{
            Spacer()
            Text(isRecording ? (speechRecognizer.transcript.isEmpty ? "Speak Now" : speechRecognizer.transcript) : "")
                .frame(width: 300, height: 200, alignment: .center)
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2)
            Spacer()
            
            Button(action: {
                speechRecognizer.stopTranscribing()
                searchText = speechRecognizer.transcript
                isRecording = false
            }) {
                Text("Stop recording to search the movie")
                    .foregroundColor(.blue)
                    .padding()
            }
            Spacer()
        }
        .onAppear{
            speechRecognizer.transcribe()
            color = .red
        }
        .onDisappear{
            color = .gray
            speechRecognizer.stopTranscribing()
            searchText = speechRecognizer.transcript
        }
    }
}


#Preview {
    SwiftUIView( isRecording: .constant(false), searchText: .constant(""), color: .constant(.gray))
}

