import CoreMedia
import Foundation
import AVFoundation


class AudioCapture: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {

    let settings = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey : 1,
        AVSampleRateKey : 44100]
    let captureSession = AVCaptureSession()
    var audioWriter: AVAssetWriter?
    var audioWriterInput: AVAssetWriterInput?
    var sessionAtSourceTime: CMTime?
    var isRecording = false
    
    
    override init() {
        super.init()
        requestAuthorization()
        let queue = DispatchQueue(label: "AudioSessionQueue", attributes: [])
        let captureDevice = getDevices(name: "Soundflower (2ch)")
        var audioInput : AVCaptureDeviceInput? = nil
        var audioOutput : AVCaptureAudioDataOutput? = nil
        do {
            try captureDevice?.lockForConfiguration()
            audioInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureDevice?.unlockForConfiguration()
            audioOutput = AVCaptureAudioDataOutput()
            audioOutput?.setSampleBufferDelegate(self, queue: queue)
        } catch {
            print("Capture devices could not be set")
            print(error.localizedDescription)
        }

        if audioInput != nil && audioOutput != nil {
            captureSession.beginConfiguration()
            if (captureSession.canAddInput(audioInput!)) {
                captureSession.addInput(audioInput!)
            } else {
                print("cannot add input")
            }
            if (captureSession.canAddOutput(audioOutput!)) {
                captureSession.addOutput(audioOutput!)
            } else {
                print("cannot add output")
            }
            captureSession.commitConfiguration()

            print("Starting capture session")
            captureSession.startRunning()
        }
        audioOutput?.connection(with: AVMediaType.audio)
    }

    func record() {
        if !isRecording {
            isRecording = true
            startRecording()
        } else {
            finishRecording(success: true)
            isRecording = false
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        print("Recording")
        
        sessionAtSourceTime = nil
        setUpWriter()
        if audioWriter?.status == .writing {
            print("status writing")
        } else if audioWriter?.status == .failed {
            print("status failed")
        } else if audioWriter?.status == .cancelled {
            print("status cancelled")
        } else if audioWriter?.status == .unknown {
            print("status unknown")
        } else {
            print("status completed")
        }
    }
    
    func finishRecording(success: Bool) {
        audioWriterInput?.markAsFinished()
        print("marked as finished")
        audioWriter?.finishWriting { [weak self] in
            self?.sessionAtSourceTime = nil
        }
        captureSession.stopRunning()
        if success {
            print("Record success")
        } else {
            print("Record fail")
        }
    }
    
    func getDevices(name: String) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInMicrophone], mediaType: AVMediaType.audio, position: AVCaptureDevice.Position.unspecified).devices
        for device in devices {
            if device.localizedName == name {
                return device
            }
        }
        return nil
    }
    
    func requestAuthorization(){
        let status = AVCaptureDevice.authorizationStatus(for: .audio)

        if status == .authorized {
        print("authorized")
          return
        }

        if status == .denied {
          print("Denied")
        }
        let semaphone = DispatchSemaphore(value: 0)
        AVCaptureDevice.requestAccess(for: .audio) { (accessGranted) in
            if accessGranted {
                print("OK")
            } else{
                print("Rejected")
            }
            semaphone.signal()
        }
        semaphone.wait()
    }
    
    func canWrite() -> Bool {
        return isRecording && audioWriter != nil && audioWriter?.status == .writing

    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        let writable = canWrite()
        if writable,
                sessionAtSourceTime == nil {
                // start writing
                sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                audioWriter?.startSession(atSourceTime: sessionAtSourceTime!)
                //print("Writing")
            }
        if writable,
                
                (audioWriterInput?.isReadyForMoreMediaData ?? false) {
                // write audio buffer
                audioWriterInput?.append(sampleBuffer)
                print("audio buffering")
            }
    }
    
    func setUpWriter() {
        do {
            let _filename = UUID().uuidString
            let audioFilename = getDocumentsDirectory().appendingPathComponent("\(_filename).m4a")
            let _audioWriter = try AVAssetWriter(outputURL: audioFilename, fileType: AVFileType.m4a)
            print(audioFilename)
            // add video input
            let _audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: settings)
            _audioWriterInput.expectsMediaDataInRealTime = true

            if _audioWriter.canAdd(_audioWriterInput) {
                _audioWriter.add(_audioWriterInput)
                print(" input added")
            } else {
                print("no input added")
            }

            // add audio input
            audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)

            _audioWriterInput.expectsMediaDataInRealTime = true

            if _audioWriter.canAdd(_audioWriterInput) {
                _audioWriter.add(_audioWriterInput)
                print("audio input added")
            }
            _audioWriter.startWriting()


            audioWriter = _audioWriter
            audioWriterInput = _audioWriterInput
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
}
