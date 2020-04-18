//
//  ViewController.swift
//  ProofScan
//
//  Created by Linando Saputra on 01/04/20.
//  Copyright © 2020 Linando Saputra. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Vision

class ProofreadViewController: UIViewController {
    
    let proofreadSession = AVCaptureSession()
    var requests = [VNRequest]()
    var photoOutout: AVCapturePhotoOutput?
    var captureBorderMinX: Float = 9999
    var captureBorderMaxX: Float = 0
    var captureBorderMinY: Float = 9999
    var captureBorderMaxY: Float = 0
    var image: UIImage?
    var kataYangDisingkat = ["yg", "utk", "km", "sy", "org", "jg", "plg", "tdk", "tp", "ap", "lg", "jd", "ak", "sdh", "kmrn", "mngkn", "lps", ""]
    let alphabet = Array("abcdefghijklmnopqrstuvwxyz")
    let number = Array("0123456789")
    let symbol = Array(",\"\'")
    let consonants = CharacterSet.letters.subtracting(CharacterSet(charactersIn: "aiueoy"))
    
    @IBOutlet weak var startScan: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
//    kata yang disingkat
//    kata baku, saya, aku, gua
//    Huruf kapital setelah titik
//    proofread imbuhan di dan ke
//    Customize proofread
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        //navigationController?.navigationBar.backgroundColor = .white
       
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(imageView.frame.size.width)
        print(imageView.frame.size.height)
        
        startLiveVideo()
        startTextRecognition()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func startScanButtonTapped(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutout?.capturePhoto(with: settings, delegate: self)
        if(self.startScan.title == "Done")
        {
            self.proofreadSession.startRunning()
            self.startScan.title = "Start Scan"
            self.imageView.layer.sublayers?.removeSubrange(1...)
            proofreadSession.startRunning()
        }
    }
    
    @IBAction func resultButtonTapped(_ sender: Any) {
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        proofreadSession.stopRunning()
        
    }
    

    func startLiveVideo() {
        
        proofreadSession.sessionPreset = AVCaptureSession.Preset.high
        
        
        
        var captureDevice: AVCaptureDevice?
        
        
        let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        for device in cameraDevices.devices {
            if device.position == .back {
                captureDevice = device
                break
            }
        }
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            if proofreadSession.canAddInput(captureDeviceInput) {
                proofreadSession.addInput(captureDeviceInput)
            }
        }
        catch {
            print("Error occured \(error)")
            return
        }
//        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
//
//        proofreadSession.addInput(deviceInput)
        photoOutout = AVCapturePhotoOutput()
        photoOutout?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        proofreadSession.addOutput(photoOutout!)
        
        //3
        let imageLayer = AVCaptureVideoPreviewLayer(session: proofreadSession)
        imageLayer.videoGravity = .resize
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        proofreadSession.startRunning()
    }
    
    
    func startTextRecognition(){
        let textRequest = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
        textRequest.usesLanguageCorrection = false
        self.requests = [textRequest]
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?)
    {
        var observationMistakeCounter = 0
        guard let observations = request.results as? [VNRecognizedTextObservation] else {print("no result"); return}
        
        DispatchQueue.main.async()
        {
            self.captureBorderMinX = 9999
            self.captureBorderMaxX = 0
            self.captureBorderMinY = 9999
            self.captureBorderMaxY = 0
            observationMistakeCounter = 0
            self.imageView.layer.sublayers?.removeSubrange(1...)
            
            for observation in observations
            {
                let observationString = observation.topCandidates(1).first?.string
                var consonantCounter = 0
                
                // kata yang disingkat khusus 3 konsonan++
                for i in observationString!
                {
                    if (i != "a" && i != "i" && i != "u" && i != "e" && i != "o" && i != "y" && i != "A" && i != "I" && i != "U" && i != "E" && i != "O" && i != "Y" && i != " " && i != "." && i != "," && i != "\"" && i != "0" && i != "2" && i != "3" && i != "4" && i != "5" && i != "6" && i != "7" && i != "8" && i != "9" && i != "(" && i != ")" && i != "!" && i != "?" && i != ":" && i != ";" && i != "[" && i != "]" && i != "{" && i != "}" && i != "/" && i != "\\" && i != "<" && i != ">")
                    {
                        consonantCounter += 1
                    }
                    else{
                        consonantCounter = 0
                    }
                    
                    if consonantCounter >= 3
                    {
                        print("ada singkatan")
                        self.drawRectangleSingkatan(char: observation)
                        break
                    }
                }
                
                
                // spasi setelah titik
                for i in 0...25
                {
                    if (observationString!.contains(".\(self.alphabet[i])")) || (observationString!.contains(". \(self.alphabet[i])"))
                    {
                        print("salah titik")
                        self.drawRectangleTitik(char: observation)
                    }
                }
                
                
                // spasi setelah koma
                guard let indexOfComa = observationString?.firstIndex(of: ",") else {continue}
                guard let indexAfterComa = observationString?.index(after: indexOfComa) else {continue}
                if observationString![indexAfterComa] != " " && observationString![indexAfterComa] != "\"" &&
                    observationString![indexAfterComa] != "\'"
                {
                    print("salah koma")
                    self.drawRectangleKoma(char: observation)
                }
            }
        }
        
    }
    
    
    func drawRectangle(char : VNRecognizedTextObservation) {
        
        let myWidth = imageView.frame.size.width
        let myHeight = imageView.frame.size.height
        
        let layerRect = CALayer()
        var rect = char.boundingBox
        
        rect.origin.x *= myWidth
        rect.size.height *= myHeight
        rect.origin.y = ((1 - rect.origin.y) * myHeight) - rect.size.height
        rect.size.width *= myWidth
        
        if(Float(rect.minX) <= self.captureBorderMinX)
        {
            self.captureBorderMinX = Float(rect.minX)
        }
        
        if(Float(rect.maxX) >= self.captureBorderMaxX)
        {
            self.captureBorderMaxX = Float(rect.maxX)
        }
        
        if(Float(rect.minY) <= self.captureBorderMinY)
        {
            self.captureBorderMinY = Float(rect.minY)
        }
        if(Float(rect.maxY) >= self.captureBorderMaxY)
        {
            self.captureBorderMaxY = Float(rect.maxY)
        }
        
        layerRect.frame = rect
        layerRect.borderWidth = 2
        layerRect.borderColor = UIColor.cyan.cgColor
        layerRect.cornerRadius = 2
        layerRect.opacity = 0.5
        self.imageView.layer.addSublayer(layerRect)
    }
    
    func drawRectangleSingkatan(char : VNRecognizedTextObservation) {
        
        let myWidth = imageView.frame.size.width
        let myHeight = imageView.frame.size.height
        
        let layerRect = CALayer()
        var rect = char.boundingBox
        
        rect.origin.x *= myWidth
        rect.size.height *= myHeight
        rect.origin.y = ((1 - rect.origin.y) * myHeight) - rect.size.height
        rect.size.width *= myWidth
        
        if(Float(rect.minX) <= self.captureBorderMinX)
        {
            self.captureBorderMinX = Float(rect.minX)
        }
        
        if(Float(rect.maxX) >= self.captureBorderMaxX)
        {
            self.captureBorderMaxX = Float(rect.maxX)
        }
        
        if(Float(rect.minY) <= self.captureBorderMinY)
        {
            self.captureBorderMinY = Float(rect.minY)
        }
        if(Float(rect.maxY) >= self.captureBorderMaxY)
        {
            self.captureBorderMaxY = Float(rect.maxY)
        }
        
        layerRect.frame = rect
        layerRect.borderWidth = 2
        layerRect.borderColor = UIColor.red.cgColor
        layerRect.cornerRadius = 2
        layerRect.opacity = 0.5
        self.imageView.layer.addSublayer(layerRect)
    }
    
    func drawRectangleKoma(char : VNRecognizedTextObservation) {
        
        let myWidth = imageView.frame.size.width
        let myHeight = imageView.frame.size.height
        
        let layerRect = CALayer()
        var rect = char.boundingBox
        
        rect.origin.x *= myWidth
        rect.size.height *= myHeight
        rect.origin.y = ((1 - rect.origin.y) * myHeight) - rect.size.height
        rect.size.width *= myWidth
        
        if(Float(rect.minX) <= self.captureBorderMinX)
        {
            self.captureBorderMinX = Float(rect.minX)
        }
        
        if(Float(rect.maxX) >= self.captureBorderMaxX)
        {
            self.captureBorderMaxX = Float(rect.maxX)
        }
        
        if(Float(rect.minY) <= self.captureBorderMinY)
        {
            self.captureBorderMinY = Float(rect.minY)
        }
        if(Float(rect.maxY) >= self.captureBorderMaxY)
        {
            self.captureBorderMaxY = Float(rect.maxY)
        }
        
        layerRect.frame = rect
        layerRect.borderWidth = 2
        layerRect.borderColor = UIColor.blue.cgColor
        layerRect.cornerRadius = 2
        layerRect.opacity = 0.5
        self.imageView.layer.addSublayer(layerRect)
    }
    
    func drawRectangleTitik(char : VNRecognizedTextObservation) {
        
        let myWidth = imageView.frame.size.width
        let myHeight = imageView.frame.size.height
        
        let layerRect = CALayer()
        var rect = char.boundingBox
        
        rect.origin.x *= myWidth
        rect.size.height *= myHeight
        rect.origin.y = ((1 - rect.origin.y) * myHeight) - rect.size.height
        rect.size.width *= myWidth
        
        if(Float(rect.minX) <= self.captureBorderMinX)
        {
            self.captureBorderMinX = Float(rect.minX)
        }
        
        if(Float(rect.maxX) >= self.captureBorderMaxX)
        {
            self.captureBorderMaxX = Float(rect.maxX)
        }
        
        if(Float(rect.minY) <= self.captureBorderMinY)
        {
            self.captureBorderMinY = Float(rect.minY)
        }
        if(Float(rect.maxY) >= self.captureBorderMaxY)
        {
            self.captureBorderMaxY = Float(rect.maxY)
        }
        
        layerRect.frame = rect
        layerRect.borderWidth = 2
        layerRect.borderColor = UIColor.green.cgColor
        layerRect.cornerRadius = 2
        layerRect.opacity = 0.5
        self.imageView.layer.addSublayer(layerRect)
    }
    
}



extension ProofreadViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate
{
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
//
//        var requestOptions:[VNImageOption : Any] = [:]
//
//        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
//            requestOptions = [.cameraIntrinsics:camData]
//        }
//
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
//
//        do {
//            try imageRequestHandler.perform(self.requests)
//        } catch {
//            print(error)
//        }
//    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation()
        {
            
            self.proofreadSession.stopRunning()
            image = UIImage(data: imageData)
            self.imageView.image = self.image
            let handler = VNImageRequestHandler(data: imageData, options: [:])
            try? handler.perform(self.requests)
            self.startScan.title = "Done"
        }
        
    }
}


