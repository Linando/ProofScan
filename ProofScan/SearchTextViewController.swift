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

class SearchTextViewController: UIViewController {
    
    let searchTextSession = AVCaptureSession()
    var requests = [VNRequest]()
    var captureBorderMinX: Float = 9999
    var captureBorderMaxX: Float = 0
    var captureBorderMinY: Float = 9999
    var captureBorderMaxY: Float = 0
    var searchedText = ""
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(imageView.frame.size.width)
        print(imageView.frame.size.height)
        startLiveVideo()
        startTextRecognition()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        searchTextSession.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchTextSession.startRunning()
        
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Enter text to search", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Start Searching", style: .default, handler: { action in
            if let text  = alert.textFields?.first?.text {
                self.searchedText = text
            }
        }))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter text here..."
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true)
        
    }
    
    
    func startLiveVideo() {
        searchTextSession.sessionPreset = AVCaptureSession.Preset.high
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        searchTextSession.addInput(deviceInput)
        searchTextSession.addOutput(deviceOutput)
        
        //3
        let imageLayer = AVCaptureVideoPreviewLayer(session: searchTextSession)
        imageLayer.videoGravity = .resize
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        searchTextSession.startRunning()
    }
    
    
    func startTextRecognition(){
        let textRequest = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
        textRequest.usesLanguageCorrection = false
        textRequest.customWords = ["susut", "luntur", " Penerima"]
        self.requests = [textRequest]
        

    }
    
    
    
    func recognizeTextHandler(request: VNRequest, error: Error?)
    {
        if(self.searchedText != "")
        {
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {print("no result"); return}
            
            DispatchQueue.main.async()
            {
                self.captureBorderMinX = 9999
                self.captureBorderMaxX = 0
                self.captureBorderMinY = 9999
                self.captureBorderMaxY = 0
                self.imageView.layer.sublayers?.removeSubrange(1...)

                for observation in observations
                {
                    if(observation.topCandidates(1).first?.string.lowercased().contains(self.searchedText.lowercased()))!
                    {
                        self.drawRectangle(char: observation)
                    }


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
    
        
    
}



extension SearchTextViewController: AVCaptureVideoDataOutputSampleBufferDelegate
{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
            
        } catch {
            print(error)
        }
    }
}

