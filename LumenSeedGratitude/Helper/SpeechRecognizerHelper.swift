//
//  SpeechRecognizerHelper.swift
//  LumenSeedGratitude
//
//  Created by e.shirashiyani on 12/28/24.
//

import Speech

class SpeechRecognizerHelper: ObservableObject {
    @Published var transcribedText: String = ""
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?

    func startRecording(completion: @escaping (Error?) -> Void) {
        // Check for microphone and speech recognition permissions
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    do {
                        try self.configureAudioSession()
                        try self.startAudioEngine()
                        self.startRecognition()
                        completion(nil)
                    } catch {
                        self.stopRecording()
                        completion(error)
                    }
                case .denied:
                    completion(SpeechRecognitionError.accessDenied)
                case .restricted:
                    completion(SpeechRecognitionError.restricted)
                case .notDetermined:
                    completion(SpeechRecognitionError.notDetermined)
                @unknown default:
                    completion(SpeechRecognitionError.unknown)
                }
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startAudioEngine() throws {
        let inputNode = audioEngine.inputNode 

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    private func startRecognition() {
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
            } else if let error = error {
                print("Recognition error: \(error.localizedDescription)")
            }
        })
    }
}

enum SpeechRecognitionError: Error, LocalizedError {
    case accessDenied
    case restricted
    case notDetermined
    case audioEngineError
    case unknown

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Speech recognition access was denied."
        case .restricted:
            return "Speech recognition is restricted on this device."
        case .notDetermined:
            return "Speech recognition permissions were not determined."
        case .audioEngineError:
            return "Audio engine could not start."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
