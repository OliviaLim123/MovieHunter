//
//  SwiftUISpeechToText.swift
//  MovieHunter
//
//  Created by Olivia Gita Amanda Lim on 29/9/2024.
//

import Foundation
import AVFoundation
import Speech
import Foundation

// MARK: SPEECH RECOGNISER CLASS
public class SpeechRecognizer: ObservableObject {
    
    // ENUM of recogniser error
    enum RecognizerError: Error {
        
        // ENUM CASES
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        // COMPUTE PROPERTY for each enum case
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    // PUBLISED PROPERTIES of Speech Recogniser
    @Published public var transcript: String = ""
    @Published public var hasStoppedRecording: Bool = false
    
    // PRIVATE PROPERTIES of Speech Recogniser
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer? = nil
    private var silenceTimer: Timer?
    private let silenceTimeout: TimeInterval = 2
    
    // INIT METHOD
    public init(localeIdentifier: String = Locale.current.identifier) {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        // Start the background task to ask permission
        Task(priority: .background) {
            do {
                // ERROR HANDLING to ensure the recogniser is not nill
                guard recognizer != nil else {
                    throw RecognizerError.nilRecognizer
                }
                // ERROR HANDLING to ensure the user has granted permission for speech recognition
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                // ERROR HANDLING to ensure the user has provided permission to use the microphone
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                // ERROR HANDLING if any errors occur during this process
                speakError(error)
            }
        }
    }
        
    // DEINIT METHOD to clean up the resources
    deinit {
        reset()
    }
    
    // METHOD to reset the recogniser by stopping the audio engine and clearing both request and task
    func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    // METHOD to start the transcribe process
    public func transcribe() {
        // Reset the transcript and recording starts
        transcript = ""
        hasStoppedRecording = false
        
        // Perform transcription in a high-priority queue
        DispatchQueue(label: "Speech Recognizer Queue", qos: .userInteractive).async { [weak self] in
            // ERROR HANDLING if the recogniser is unavailable
            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                self?.speakError(RecognizerError.recognizerIsUnavailable)
                return
            }
            
            do {
                // Prepare the audio engine and request for recognition
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.request = request
                
                // Set the audio session to active for recording
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                // Start the recognition task
                self.task = recognizer.recognitionTask(with: request) { result, error in
                    // Check if final result is recived and any error occurred
                    let receivedFinalResult = result?.isFinal ?? false
                    let receivedError = error != nil
                    
                    // Restart the silence timer each time speech is detected
                    self.restartSilenceTimer()
                    
                    // Stop recording if the final result is received or an error occurs
                    if receivedFinalResult || receivedError {
                        audioEngine.stop()
                        audioEngine.inputNode.removeTap(onBus: 0)
                        self.hasStoppedRecording = true
                    }
                    
                    // Update the transcript with the recognised speech
                    if let result = result {
                        self.speak(result.bestTranscription.formattedString)
                    }
                    
                    // If an error occurred, reset and try transcribing again
                    if receivedError {
                        self.reset()
                        self.transcribe()
                    }
                }
            } catch {
                // ERROR HANDLING to reset and display the error
                self.reset()
                self.speakError(error)
            }
        }
    }
       
    // PRIVATE METHOD to prepare the audio engine and configure it for speech recognition
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        // Configure the audio session for recording
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Capture the microphone input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            // Append captured audio to the recognition request
            request.append(buffer)
        }
        
        // Prepare and start the audio engine
        audioEngine.prepare()
        try audioEngine.start()
        return (audioEngine, request)
    }
    
    // METHOD to stop transcribing and reset the recogniser
    public func stopTranscribing() {
        reset()
        self.hasStoppedRecording = true
    }
    
    // PRIVATE METHOD to handle and display error by updating the transcript with error messages
    private func speakError(_ error: Error) {
        var errorMessage = ""
        // ERROR HANDLING and display the error message
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        transcript = "<< \(errorMessage) >>"
    }
    
    // PRIVATE METHOD to update the transcript with the recognised speech
    private func speak(_ message: String) {
        transcript = message
    }
    
    // PRIVATE METHOD to restart the silence timer.
    private func restartSilenceTimer() {
        // Cancel any existing timer
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceTimeout, repeats: false) { [weak self] _ in
            // Stop transcribing after silence
            self?.stopTranscribing()
        }
    }
    
    // PRIVATE METHOD to reset the silence timer
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
}

@available(macOS 10.15, *)
// MARK: SF SPEECH RECOGNISER EXTENSION
extension SFSpeechRecognizer {
    
    // STATIC FUNCTION to check if the app has authorisation for speech recognition
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

// MARK: AV AUDIO SESSION EXTENSION
extension AVAudioSession {
    
    // FUNCTION to check if the app has permission to use the microphone
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
