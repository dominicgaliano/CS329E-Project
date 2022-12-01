//
//  ScannerViewController.swift
//  CS329E-Project
//
//  Created by Hans Wang on 11/7/22.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var message: UILabel!
    var delegate: UIViewController!
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrame: UIView?
    var groupCode = ""
    
    private let supportedCodeTypes =
    [AVMetadataObject.ObjectType.upce,
     AVMetadataObject.ObjectType.code39,
     AVMetadataObject.ObjectType.code39Mod43,
     AVMetadataObject.ObjectType.code93,
     AVMetadataObject.ObjectType.code128,
     AVMetadataObject.ObjectType.ean8,
     AVMetadataObject.ObjectType.ean13,
     AVMetadataObject.ObjectType.aztec,
     AVMetadataObject.ObjectType.pdf417,
     AVMetadataObject.ObjectType.itf14,
     AVMetadataObject.ObjectType.dataMatrix,
     AVMetadataObject.ObjectType.interleaved2of5,
     AVMetadataObject.ObjectType.qr]
    
    
    @IBAction func backButton(_ sender: Any) {
        let otherVC = delegate as! fillGroupCode
        otherVC.updateTextField(code: groupCode)
        self.dismiss(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Adding unique font
        UILabel.appearance().substituteFontName = "American Typewriter";
        UITextView.appearance().substituteFontName = "American Typewriter";
        UITextField.appearance().substituteFontName = "American Typewriter";
        UIButton.appearance().substituteFontName = "American Typewriter";
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        else {return}
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
            view.bringSubviewToFront(message)
            view.bringSubviewToFront(topBar)
            
            qrCodeFrame = UIView()
            if let qrcodeFrame = qrCodeFrame {
                qrcodeFrame.layer.borderColor = UIColor.systemGreen.cgColor
                qrcodeFrame.layer.borderWidth = 2
                view.addSubview(qrcodeFrame)
                view.bringSubviewToFront(qrcodeFrame)
            }
            
        } catch {return}
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            qrCodeFrame?.frame = CGRect.zero
            message.text = "No group identifier is detected"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrame?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                message.text = "Success! Group Code: \(metadataObj.stringValue ?? "")"
                groupCode = metadataObj.stringValue!
            }
        }
    }
}
