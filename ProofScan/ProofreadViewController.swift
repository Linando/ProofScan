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
    var captureBorderMinX: Float = 9999
    var captureBorderMaxX: Float = 0
    var captureBorderMinY: Float = 9999
    var captureBorderMaxY: Float = 0
    
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
        proofreadSession.startRunning()
        
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
        
        proofreadSession.stopRunning()
    }
    
    
    func startLiveVideo() {
        proofreadSession.sessionPreset = AVCaptureSession.Preset.high
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        proofreadSession.addInput(deviceInput)
        proofreadSession.addOutput(deviceOutput)
        
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
                    self.drawRectangle(char: observation)
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
    
    //    func highlightWord(box: VNTextObservation) {
    //        guard let boxes = box.characterBoxes else {
    //            return
    //        }
    //
    //        var maxX: CGFloat = 9999.0
    //        var minX: CGFloat = 0.0
    //        var maxY: CGFloat = 9999.0
    //        var minY: CGFloat = 0.0
    //
    //        for char in boxes {
    //            if char.bottomLeft.x < maxX {
    //                maxX = char.bottomLeft.x
    //            }
    //            if char.bottomRight.x > minX {
    //                minX = char.bottomRight.x
    //            }
    //            if char.bottomRight.y < maxY {
    //                maxY = char.bottomRight.y
    //            }
    //            if char.topRight.y > minY {
    //                minY = char.topRight.y
    //            }
    //        }
    //
    //        let xCord = maxX * imageView.frame.size.width
    //        let yCord = (1 - minY) * imageView.frame.size.height
    //        let width = (minX - maxX) * imageView.frame.size.width
    //        let height = (minY - maxY) * imageView.frame.size.height
    //
    //        let outline = CALayer()
    //        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
    //        outline.borderWidth = 2.0
    //        outline.borderColor = UIColor.red.cgColor
    //
    //        imageView.layer.addSublayer(outline)
    //    }
    
    //    func highlightLetters(box: VNRectangleObservation)
    //    {
    //        let xCord = box.topLeft.x * imageView.frame.size.width
    //        let yCord = (1 - box.topLeft.y) * imageView.frame.size.height
    //        let width = (box.topRight.x - box.bottomLeft.x) * imageView.frame.size.width
    //        let height = (box.topLeft.y - box.bottomLeft.y) * imageView.frame.size.height
    //
    //        let outline = CALayer()
    //        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
    //        outline.borderWidth = 1.0
    //        outline.borderColor = UIColor.blue.cgColor
    //
    //        imageView.layer.addSublayer(outline)
    //    }
    
}



extension ProofreadViewController: AVCaptureVideoDataOutputSampleBufferDelegate
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


