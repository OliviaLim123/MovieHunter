//
//  TranscribedTextFieldView.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import SwiftUI
public struct TranscribedTextFieldView: View{
    @State var color:Color
    @State var isRecording:Bool
    @Binding var searchText:String
    // default values
    var placeHolder:String
    var micIconWidth:CGFloat
    var micIconHeight:CGFloat
    public init(color: Color = .black, isRecording: Bool = false, searchText: Binding<String>, placeHolder: String = "Tap the microphone to start", micIconWidth: CGFloat = 15, micIconHeight: CGFloat = 25) {
        self.color = color
        self.isRecording = isRecording
        self._searchText = searchText
        self.placeHolder = placeHolder
        self.micIconWidth = micIconWidth
        self.micIconHeight = micIconHeight
    }
    public var body: some View{
        HStack{
            Image(systemName: "mic.fill")
                .resizable()
                .frame(width: micIconWidth, height: micIconHeight)
                .foregroundStyle( color )
                .onTapGesture {
                    isRecording.toggle()
                }
            TextField("", text: $searchText,prompt: Text(placeHolder))
//                .font(.system(size: textFieldSize))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .sheet(isPresented: $isRecording){
                SwiftUIView(isRecording: self.$isRecording, searchText: self.$searchText, color: self.$color)
                    .presentationDetents([.medium, .fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
    }
}
