//
//  ViewController.swift
//  ProofScan
//
//  Created by Linando Saputra on 01/04/20.
//  Copyright © 2020 Linando Saputra. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import AVKit
import Vision

class ProofreadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let proofreadSession = AVCaptureSession()
    var requests = [VNRequest]()
    var photoOutout: AVCapturePhotoOutput?
    var captureBorderMinX: Float = 9999
    var captureBorderMaxX: Float = 0
    var captureBorderMinY: Float = 9999
    var captureBorderMaxY: Float = 0
    var image: UIImage?
    var kataYangDisingkat = ["yg", "utk", "km", "sy", "org", "jg", "plg", "tdk", "tp", "ap", "lg", "jd", "ak", "sdh", "kmrn", "mngkn", "lps", "ad", "bs", "nggk", "ngk", "trs"]
    let alphabet = Array("abcdefghijklmnopqrstuvwxyz")
    let number = Array("0123456789")
    let symbol = Array(",\"\'")
    let consonants = CharacterSet.letters.subtracting(CharacterSet(charactersIn: "aiueoy"))
    var singkatanMistakeString = [""]
    var titikMistakeString = [""]
    var komaMistakeString = [""]
    var multipleMistakeString = [""]
    var searchedText = ""
    var dummyWord = "a b c"
    
    var currentImage: UIImage!
    
    var tempObservations = [VNRecognizedTextObservation]()
    var tempObservationString = [""]
    var observationResults = [VNRecognizedTextObservation]()
    //var tempObservation: VNRecognizedTextObservation
    
    
    @IBOutlet weak var resultButton: UIBarButtonItem!
    @IBOutlet weak var startScan: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var tapHereToImportLabel: UILabel!
    @IBOutlet weak var squareArrowUpImage: UIImageView!
    
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
        
        //startLiveVideo()
        startTextRecognition()
        resultButton.isEnabled = false
        startScan.isEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func importImageButton(_ sender: Any) {
        let picker = UIImagePickerController()
        self.imageView.layer.sublayers?.removeSubrange(0...)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //guard let image = info[.editedImage] as? UIImage else { return }
        guard let image = info[.originalImage] as? UIImage else { return }

        dismiss(animated: true)
        
        currentImage = image
        self.imageView.image = currentImage
        
        startScan.isEnabled = true
        resultButton.isEnabled = true
        tapHereToImportLabel.isHidden = true
        squareArrowUpImage.isHidden = true
    }
    
    @IBAction func resultButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Enter text to search", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Start Searching", style: .default, handler: { action in
            if let text  = alert.textFields?.first?.text {
                self.searchedText = text
//                print("UIImage Orientation = \(self.imageView.image?.imageOrientation)")
//                print(self.imageView.image?.imageOrientation.rawValue)
                //print("CGImage Orientation = \(self.imageView.image?.cgImage)")
                let handler = VNImageRequestHandler(cgImage: (self.imageView.image?.cgImage!)!, options: [:])
                let handler2 = VNImageRequestHandler(cgImage: (self.imageView.image?.cgImage!)!, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: [:])
                if self.imageView.image?.imageOrientation.rawValue == 0
                {
                    try? handler.perform(self.requests)
                }
                else
                {
                    try? handler2.perform(self.requests)
                }
                
            }
        }))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter text here..."
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true)
        
        
    }
    
    @IBAction func startScanButtonTapped(_ sender: Any) {
        
//        if(self.startScan.title == "Done")
//        {
//            self.proofreadSession.startRunning()
//            self.startScan.title = "Start Scan"
//            self.imageView.layer.sublayers?.removeSubrange(1...)
//
//        }
//        else
//        {
//            let settings = AVCapturePhotoSettings()
//            photoOutout?.capturePhoto(with: settings, delegate: self)
//        }
    }
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.searchedText = ""
        //self.imageView.layer.sublayers?.removeSubrange(1...)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
//        if startScan.title == "Done"
//        {
//            proofreadSession.stopRunning()
//        }
        
        
    }
    

//    func startLiveVideo() {
//
//        proofreadSession.sessionPreset = AVCaptureSession.Preset.high
//
//        var captureDevice: AVCaptureDevice?
//
//        let cameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
//        for device in cameraDevices.devices {
//            if device.position == .back {
//                captureDevice = device
//                break
//            }
//        }
//
//        do {
//            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
//            if proofreadSession.canAddInput(captureDeviceInput) {
//                proofreadSession.addInput(captureDeviceInput)
//            }
//        }
//        catch {
//            print("Error occured \(error)")
//            return
//        }
//
//        photoOutout = AVCapturePhotoOutput()
//        photoOutout?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
//        proofreadSession.addOutput(photoOutout!)
//
//        let imageLayer = AVCaptureVideoPreviewLayer(session: proofreadSession)
//        imageLayer.videoGravity = .resize
//        imageLayer.frame = imageView.bounds
//        imageView.layer.addSublayer(imageLayer)
//        proofreadSession.startRunning()
//    }
    
    
    func startTextRecognition(){
        let textRequest = VNRecognizeTextRequest(completionHandler: self.recognizeTextHandler)
        textRequest.usesLanguageCorrection = false
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
                self.imageView.layer.sublayers?.removeSubrange(0...)
                self.tempObservations = []
                self.observationResults = []
                
                //                    if(observation.topCandidates(1).first?.string.lowercased().contains(self.searchedText.lowercased()))!
                //                    {
                //                        self.drawRectangle(char: observation)
                //                    }
                //                    print(observation.topCandidates(1).first?.string)

//                if UserDefaults.standard.bool(forKey: "ImageIgnorePunctuation") == true
//                {
//                    var IgnorePunctuationTemp = self.tempObservations
//                    self.tempObservations = []
//                    for observation in IgnorePunctuationTemp
//                    {
//                        self.tempObservations.append(observation)
//                        self.tempObservationString.append(observation.topCandidates(1).first!.string)
//                    }
//                }
//
//
//                if UserDefaults.standard.bool(forKey: "ImageIgnoreWhiteSpace") == true
//                {
//                    var IgnoreWhiteSpaceTemp = self.tempObservations
//                    self.tempObservations = []
//                    for observation in IgnoreWhiteSpaceTemp
//                    {
//                        var temp = observation.topCandidates(1).first?.string.lowercased().components(separatedBy: " ")
//                        for word in temp!
//                        {
//                            if word.suffix(self.searchedText.count).lowercased() == self.searchedText.lowercased()
//                            {
//                                self.tempObservations.append(observation)
//                            }
//                        }
//                    }
//                }
                    
                if UserDefaults.standard.bool(forKey: "ImageMatchCase") == true
                {
                    for observation in observations
                    {
                        var temp = observation.topCandidates(1).first?.string
                        if UserDefaults.standard.bool(forKey: "ImageIgnorePunctuation") == true
                        {
                            temp?.removeAll(where: {$0.isPunctuation})
                        }
                        if UserDefaults.standard.bool(forKey: "ImageIgnoreWhiteSpace") == true
                        {
                            temp?.removeAll(where: {$0.isWhitespace})
                        }
                        
                        if(temp!.contains(self.searchedText))
                        {
                            //self.drawRectangle(char: observation)
                            self.tempObservations.append(observation)
                        }
                    }
                }
                else
                {
                    self.tempObservations = observations
                }
                
                
                if UserDefaults.standard.bool(forKey: "ImageWholeWord") == true
                {
                    var wholeWordTemp = self.tempObservations
                    self.tempObservations = []
                    for observation in wholeWordTemp
                    {
                        var wholeWordString = observation.topCandidates(1).first?.string.lowercased().components(separatedBy: " ")
                        
                        for eachWord in wholeWordString!
                        {
                            var temp = eachWord
                            if UserDefaults.standard.bool(forKey: "ImageIgnorePunctuation") == true
                            {
                                temp.removeAll(where: {$0.isPunctuation})
                            }
                            
                            if (temp.contains(self.searchedText.lowercased()))
                            {
                                self.tempObservations.append(observation)
                            }
                        }
                        
                    }
                }
                
                
                if UserDefaults.standard.bool(forKey: "ImageMatchPrefix") == true
                {
                    var MatchPrefixTemp = self.tempObservations
                    self.tempObservations = []
                    for observation in MatchPrefixTemp
                    {
                        var temp = observation.topCandidates(1).first?.string.lowercased().components(separatedBy: " ")
                        for word in temp!
                        {
                            
                            var matchPrefixString = word
                            if UserDefaults.standard.bool(forKey: "ImageIgnorePunctuation") == true
                            {
                                matchPrefixString.removeAll(where: {$0.isPunctuation})
                            }
                            
                            if matchPrefixString.prefix(self.searchedText.count).lowercased() == self.searchedText.lowercased()
                            {
                                self.tempObservations.append(observation)
                            }
                        }
                    }
                }
                
                
                if UserDefaults.standard.bool(forKey: "ImageMatchSuffix") == true
                {
                    var MatchSuffixTemp = self.tempObservations
                    self.tempObservations = []
                    for observation in MatchSuffixTemp
                    {
                        var temp = observation.topCandidates(1).first?.string.lowercased().components(separatedBy: " ")
                        for word in temp!
                        {
                            var matchSuffixString = word
                            if UserDefaults.standard.bool(forKey: "ImageIgnorePunctuation") == true
                            {
                                matchSuffixString.removeAll(where: {$0.isPunctuation})
                            }
                            
                            if word.suffix(self.searchedText.count).lowercased() == self.searchedText.lowercased()
                            {
                                self.tempObservations.append(observation)
                            }
                        }
                    }
                }
                
                
                
                
                
                
                for x in self.tempObservations
                {
                    
                    self.drawRectangle(char: x)
                }


            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? ResultViewController
//        {
//            vc.mistakeKomaStringResult = komaMistakeString
//            vc.mistakeTitikStringResult = titikMistakeString
//            vc.mistakeSingkatanStringResult = singkatanMistakeString
//        }
//    }
    
    
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



//extension ProofreadViewController: AVCapturePhotoCaptureDelegate
//{
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//
//        if let imageData = photo.fileDataRepresentation()
//        {
//            self.proofreadSession.stopRunning()
//            image = UIImage(data: imageData)
//            self.imageView.image = self.image
//            let handler = VNImageRequestHandler(data: imageData, options: [:])
//            try? handler.perform(self.requests)
//            self.startScan.title = "Done"
//            self.resultButton.isEnabled = true
//        }
//
//    }
//}

//extension UIImage {
//
//    func resize(targetSize: CGSize) -> UIImage {
//        return UIGraphicsImageRenderer(size:targetSize).image { _ in
//            self.draw(in: CGRect(origin: .zero, size: targetSize))
//        }
//    }
//
//    func resize(scaledToWidth desiredWidth: CGFloat) -> UIImage {
//        let oldWidth = size.width
//        let scaleFactor = desiredWidth / oldWidth
//
//        let newHeight = size.height * scaleFactor
//        let newWidth = oldWidth * scaleFactor
//        let newSize = CGSize(width: newWidth, height: newHeight)
//
//        return resize(targetSize: newSize)
//    }
//
//    func resize(scaledToHeight desiredHeight: CGFloat) -> UIImage {
//        let scaleFactor = desiredHeight / size.height
//        let newWidth = size.width * scaleFactor
//        let newSize = CGSize(width: newWidth, height: desiredHeight)
//
//        return resize(targetSize: newSize)
//    }
//}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
