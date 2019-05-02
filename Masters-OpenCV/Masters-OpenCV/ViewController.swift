//
//  ViewController.swift
//  Masters-OpenCV
//
//  Created by Brian Malsan on 5/1/19.
//  Copyright © 2019 Brian Malsan. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation
import CoreImage
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imgView: UIImageView!
    var previewLayer: AVCaptureVideoPreviewLayer?
    private let context = CIContext()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureCamera()
    }
    func configureCamera(){
        //Start capture session
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        captureSession.startRunning()
        
        // Add input for capture
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(captureInput)
        
        // Add preview layer
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .landscapeRight
        
        //view.layer.insertSublayer(self.previewLayer!, at: 0)
        //self.previewLayer?.frame = view.frame
        
        
        // Add output for capture
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
    
        //let newImage = OpenCVWrapper.makeGray(uiImage)
        let newImage = OpenCVWrapper.doCanny(uiImage)
        
        DispatchQueue.main.async { [unowned self] in
            self.imgView.image = newImage
        }
        
    
    }

}
