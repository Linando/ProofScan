//
//  ViewController.swift
//  ProofScan
//
//  Created by Linando Saputra on 01/04/20.
//  Copyright © 2020 Linando Saputra. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    var cameraDevice: AVCaptureDevice?
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    var rectRequests = [VNRequest]()
    @IBOutlet weak var cameraView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startLiveVideo()
        startTextRecognition()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        cameraView.layer.sublayers?[0].frame = cameraView.bounds
    }
    
    func startLiveVideo() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
           
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(imageLayer)
            
        session.startRunning()
    }
    
    func startTextRecognition(){
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.recognizeTextHandler)
        textRequest.reportCharacterBoxes = true
        self.requests = [textRequest]
        
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?)
    {
//            guard let observations = request.results as? [VNRecognizedTextObservation] else {print("no result"); return}
//
//            DispatchQueue.main.async()
//            {
//                for observation in observations
//                {
//
//                }
//            }
        
            guard let observations = request.results else {
                print("no result")
                return
            }
            
            let result = observations.map({$0 as? VNTextObservation})
            
            DispatchQueue.main.async() {
                self.cameraView.layer.sublayers?.removeSubrange(1...)
                for region in result {
                    guard let rg = region else {
                        continue
                    }
                    
                    self.highlightWord(box: rg)
                    
                    if let boxes = region?.characterBoxes {
                        for characterBox in boxes {
                            self.highlightLetters(box: characterBox)
                        }
                    }
                }
            }
        
    }
    
    func highlightWord(box: VNTextObservation) {
        guard let boxes = box.characterBoxes else {
            return
        }
            
        var maxX: CGFloat = 9999.0
        var minX: CGFloat = 0.0
        var maxY: CGFloat = 9999.0
        var minY: CGFloat = 0.0
            
        for char in boxes {
            if char.bottomLeft.x < maxX {
                maxX = char.bottomLeft.x
            }
            if char.bottomRight.x > minX {
                minX = char.bottomRight.x
            }
            if char.bottomRight.y < maxY {
                maxY = char.bottomRight.y
            }
            if char.topRight.y > minY {
                minY = char.topRight.y
            }
        }
            
        let xCord = maxX * cameraView.frame.size.width
        let yCord = (1 - minY) * cameraView.frame.size.height
        let width = (minX - maxX) * cameraView.frame.size.width
        let height = (minY - maxY) * cameraView.frame.size.height
            
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor
            
        cameraView.layer.addSublayer(outline)
    }
    
    func highlightLetters(box: VNRectangleObservation)
    {
        let xCord = box.topLeft.x * cameraView.frame.size.width
        let yCord = (1 - box.topLeft.y) * cameraView.frame.size.height
        let width = (box.topRight.x - box.bottomLeft.x) * cameraView.frame.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * cameraView.frame.size.height
            
        let outline = CALayer()
        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.blue.cgColor
        
        cameraView.layer.addSublayer(outline)
    }
    
}



extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate
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

