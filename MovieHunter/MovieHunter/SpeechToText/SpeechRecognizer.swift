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

// A helper for transcribing speech to text using SFSpeechRecognizer and AVAudioEngine.
public class SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    @Published public var transcript: String = ""
    @Published public var hasStoppedRecording: Bool = false
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer? = nil
    
    private var silenceTimer: Timer?
    private let silenceTimeout: TimeInterval = 2
    
    public init(localeIdentifier: String = Locale.current.identifier) {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        
        Task(priority: .background) {
            do {
                guard recognizer != nil else {
                    throw RecognizerError.nilRecognizer
                }
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                speakError(error)
            }
        }
    }
        
    deinit {
        reset()
    }
    
    // Reset the speech recognizer.
    func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    /**
            Begin transcribing audio.
         
            Creates a `SFSpeechRecognitionTask` that transcribes speech to text until you call `stopTranscribing()`.
            The resulting transcription is continuously written to the published `transcript` property.
         */
    public func transcribe() {
        transcript = ""
        hasStoppedRecording = false
        
        DispatchQueue(label: "Speech Recognizer Queue", qos: .userInteractive).async { [weak self] in
            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                self?.speakError(RecognizerError.recognizerIsUnavailable)
                return
            }
            
            do {
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.request = request
                
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                self.task = recognizer.recognitionTask(with: request) { result, error in
                    let receivedFinalResult = result?.isFinal ?? false
                    let receivedError = error != nil // != nil mean there's error (true)
                    
                    // Restart the silence timer each time speech is detected
                    self.restartSilenceTimer()
                    
                    if receivedFinalResult || receivedError {
                        audioEngine.stop()
                        audioEngine.inputNode.removeTap(onBus: 0)
                        self.hasStoppedRecording = true
                    }
                    
                    if let result = result {
                        self.speak(result.bestTranscription.formattedString)
                    }
                    
                    if receivedError {
                        self.reset()
                        self.transcribe()
                    }
                }
            } catch {
                self.reset()
                self.speakError(error)
            }
        }
    }
        
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    // Stop transcribing audio.
    public func stopTranscribing() {
        reset()
        self.hasStoppedRecording = true
    }
    
    private func speakError(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        transcript = "<< \(errorMessage) >>"
    }
    
    private func speak(_ message: String) {
        transcript = message
    }
    
    private func restartSilenceTimer() {
        silenceTimer?.invalidate() // Cancel any existing timer
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceTimeout, repeats: false) { [weak self] _ in
            self?.stopTranscribing() // Stop transcribing after silence
        }
    }
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
}

@available(macOS 10.15, *)
extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
